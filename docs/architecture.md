# Architecture & State Management

KukuFiti Mobile employs a clean, layered architectural pattern designed to keep UI components decoupled from business logic and data fetching. The stack is heavily reliant on **Flutter Riverpod** for state management and dependency injection.

## Project Layers

Every major feature in `lib/features/` is split into:

1. **Data Layer** (`data/`)
   - **DTOs**: Data Transfer Objects (using `json_serializable` and `freezed`) that represent raw JSON from the API.
   - **Repositories**: Implementations of abstract repository interfaces. These classes use `ApiClient.instance` to make HTTP calls. They catch network exceptions and return typed responses or generic errors.

2. **Domain Layer** (`domain/`)
   - **Entities**: Pure Dart classes representing business objects (e.g., `Flock`, `User`). They contain no Flutter or JSON parsing dependencies.
   - **Repository Interfaces**: Abstract classes defining the contract for data fetching (e.g., `IFlockRepository`).
   - **Use Cases** (Optional): Encapsulate a single business operation (e.g., `CalculateFeedRequirementUseCase`) if the logic is complex enough to warrant separation from the state controller.

3. **Presentation Layer** (`presentation/`)
   - **Controllers**: Riverpod `Notifier` or `AsyncNotifier` classes. They hold the UI state (loading, error, data). They invoke the repositories/use-cases and catch errors to display to the user.
   - **Screens / Widgets**: Flutter UI components that use `ref.watch()` to bind to controller states.

## State Management: Riverpod

The application uses Riverpod almost exclusively for state. 

### Provider Types Used:
- **`NotifierProvider` / `AsyncNotifierProvider`**: Used for mutable state where actions (methods on the Notifier) mutate the state. (e.g., `AuthNotifier`, `FlockNotifier`).
- **`Provider`**: Used for static dependencies, like the Router configuration (`routerProvider`) or providing an instance of a repository.
- **`FutureProvider`**: Used for simple read-only async data fetches.

### The App State Tree
State is localized where possible. 
- *Global State*: User settings, Theme preference, Auth token, and Connectivity status live in globally accessible providers in `lib/providers/`.
- *Feature State*: A specific batch's details or the community feed lives within its feature module. When a user logs out, we instruct Riverpod to invalidate these providers to wipe user data from memory.

## Navigation: go_router
We use `go_router` to provide deep-linking capability, named routes, and imperative navigation.
The `AppRouter` defines the overall routing graph.

**Stateful Shell Route**:
For the main authenticated experience, `StatefulShellRoute` is used. This allows us to have a persistent Bottom Navigation Bar while preserving the navigation stack of each independent tab (Home, Batches, AI, Analytics, Settings).

**Guard/Redirect**:
`go_router` has a `redirect` callback that watches the `authProvider`. If a user's token expires, `authProvider` state updates, go_router re-evaluates the redirect, and automatically boots the user back to the `/login` screen without writing manual navigation logic in UI code.
