# Offline Support & Synchronization

Agricultural environments often have patchy internet connectivity. KukuFiti relies on **Hive** and a custom **SyncService** to provide a seamless offline-first experience.

## The Two Hive Boxes

### 1. `offline_cache`
**Purpose**: Store GET request responses to serve data when the app cannot reach the server.
**Implementation**: Currently utilized primarily for saving application configurations (like the critical `API_URL` when overriding the default backend). To expand to caching API responses, repositories check `isConnected`. If false, they attempt to read the last known JSON payload from this box associated with the endpoint URL.

### 2. `offline_sync_queue`
**Purpose**: Prevent data loss when users attempt mutations (POST, PUT, DELETE) while offline.
**Implementation**: Handled automatically by the `ApiClient`'s interceptors.

## How Queueing Works

1. **Attempt Request**: The app attempts to make a `POST /events/mortality` request using `ApiClient.instance`.
2. **Network Failure**: The device is offline, causing a `DioException` of type `connectionError` or `connectionTimeout`.
3. **Interceptor Trap**: The `onError` interceptor explicitly catches `connectionError` or timeout types.
4. **Method Verification**: If the request method is **not** `GET` (meaning it's a mutation), the interceptor calls `SyncService.queueRequest(requestOptions)`.
5. **Serialization**: The request path, method, headers, and body are serialized and saved to the `offline_sync_queue` Hive box.
6. **Graceful Fail**: The interceptor resolves the failure by returning a fake `HTTP 202 Accepted` response back to the app with a message: `Offline: Request queued for sync.` This allows the UI to show a "Saved offline" toast instead of a fatal error crash.

## Idempotency is Critical
Because queued requests might be transmitted multiple times if connectivity is flaky during sync, **all offline-capable write endpoints must be idempotent**.
KukuFiti achieves this by generating standard UUIDs for events *on the client side*. 
For example, a new mortality event payload looks like this:
```json
{
  "event_id": "c9e782ea-b184-4860-9d0b-6a05e26b802a",
  "count": 2,
  "cause": "Unknown"
}
```
If the sync queue sends this payload twice, the backend `POST /events/mortality` uses `event_id` as the primary key and gracefully handles or ignores the duplicate insert, preventing double-counting mortality.

## Queue Draining (Replay)

When the app detects a connection (or on startup if connectivity exists), `SyncService.syncPendingRequests()` is invoked.
1. It reads all serialized requests from Hive.
2. It attempts to replay them one-by-one via Dio.
3. If a request succeeds (HTTP 2xx), it is deleted from the queue.
4. If a request fails due to a client error (e.g., HTTP 400 Bad Request, meaning the payload was definitively invalid), it is also deleted to prevent infinite loop blockage.
5. If it fails due to network again (HTTP 502, timeout), it remains in the queue for the next sync cycle.
