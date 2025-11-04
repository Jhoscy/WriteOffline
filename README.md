# WriteOffline - Offline-First Project Manager

A Flutter application demonstrating offline-first architecture using Isar (local database) and Appwrite (backend) with clean architecture principles and Last-Write-Wins (LWW) conflict resolution.

> **Note**: This implementation uses the standard `isar` package (version 3.1.0+1). While the project initially aimed to use `isar_community`, the standard Isar package provides the same offline-first capabilities and is fully compatible with the architecture described.

## Features

- **Offline-First**: All data is stored locally first, then synced to the cloud when online
- **Project Management**: Create, edit, and delete projects with details like budget, dates, and status
- **Task Management**: Manage tasks for each project with due dates and descriptions
- **Automatic Sync**: Transparent synchronization with Last-Write-Wins (LWW) conflict resolution
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **State Management**: Powered by Riverpod
- **Real-time Updates**: Watch streams for live data updates

## Architecture

The app follows clean architecture principles:

```
lib/
├── core/
│   └── services/          # Core services (connectivity, sync)
├── domain/
│   ├── entities/          # Business entities
│   └── repositories/      # Repository interfaces
├── data/
│   ├── models/            # Data models with Isar annotations
│   ├── datasources/       # Data sources (local & remote)
│   │   ├── local/         # Isar implementation
│   │   └── remote/        # Appwrite implementation
│   └── repositories/      # Repository implementations
└── presentation/
    ├── providers/         # Riverpod providers
    └── screens/           # UI screens
```

## Tech Stack

- **Flutter**: UI framework
- **Isar Community**: Local database
- **Appwrite**: Backend as a Service
- **Riverpod**: State management
- **Connectivity Plus**: Network status monitoring

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Isar Database Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Appwrite

1. Create an account at [Appwrite Cloud](https://cloud.appwrite.io/) or self-host
2. Create a new project
3. Create a new database
4. Create two collections:
   - **projects** with attributes:
     - projectName (string, max 128)
     - description (string)
     - startDate (datetime, optional)
     - endDate (datetime, optional)
     - budget (double)
     - status (string)
     - createdAt (datetime)
     - updatedAt (datetime)
     - isDeleted (boolean)
   - **tasks** with attributes:
     - name (string)
     - description (string)
     - dueDate (datetime, optional)
     - projectId (string)
     - createdAt (datetime)
     - updatedAt (datetime)
     - isDeleted (boolean)

### 4. Configure Environment Variables

1. Copy `environments/.env.example` to `environments/.env`
2. Fill in your Appwrite credentials:

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_DATABASE_ID=your_database_id
APPWRITE_PROJECTS_COLLECTION_ID=projects
APPWRITE_TASKS_COLLECTION_ID=tasks
```

### 5. Run the App

```bash
flutter run
```

## How It Works

### Offline-First Flow

1. **User Action**: User creates/updates/deletes a project or task
2. **Local Write**: Data is immediately written to Isar (local database)
3. **Sync Flag**: Item is marked with `needsSync = true`
4. **Background Sync**: When online, sync orchestrator:
   - Pushes local changes to remote (Appwrite)
   - Pulls remote changes to local
   - Resolves conflicts using LWW (Last-Write-Wins)
5. **Transparent**: User doesn't need to worry about sync status

### LWW Conflict Resolution

When the same entity is modified both locally and remotely:
- Compare `updatedAt` timestamps
- The version with the latest timestamp wins
- Losing version is overwritten

### Data Flow

```
UI Layer (Riverpod Providers)
    ↓
Domain Layer (Entities & Repository Interfaces)
    ↓
Data Layer (Repository Implementations)
    ↓
Local Datasource (Isar) ←→ Sync Orchestrator ←→ Remote Datasource (Appwrite)
```

## Key Components

### Sync Orchestrator
- Monitors connectivity changes
- Performs periodic sync (every 5 minutes)
- Implements LWW conflict resolution
- Manages sync status

### Repositories
- `ProjectLocalRepositoryImpl`: Local project operations
- `ProjectRemoteRepositoryImpl`: Remote project operations
- `TaskLocalRepositoryImpl`: Local task operations
- `TaskRemoteRepositoryImpl`: Remote task operations

### Data Sources
- Abstracted to allow swapping backends (Appwrite, Supabase, etc.)
- Local: Isar database
- Remote: Appwrite (can be replaced with other backends)

## Project Status

✅ Fully functional offline-first app with:
- Complete CRUD operations for projects and tasks
- Automatic sync with LWW conflict resolution
- Clean architecture implementation
- Riverpod state management
- Beautiful Material Design UI

## Future Enhancements

- User authentication
- Collaborative features
- File attachments
- Search and filtering
- Analytics and reports
- Dark mode

## License

MIT License
