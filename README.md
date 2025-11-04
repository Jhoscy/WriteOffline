# WriteOffline - Offline-First Project Manager

A production-ready Flutter application demonstrating true offline-first architecture using Isar (local database) and Appwrite (backend) with clean architecture principles and intelligent auto-sync.

> **Note**: This implementation uses `isar_community` package (version 3.3.0-dev.3) with Appwrite's latest TablesDB API for optimal performance and future compatibility.

## ✨ Key Features

- **🔄 Automatic Sync**: Zero-configuration auto-sync based on connectivity
  - **Online**: Changes sync to cloud immediately
  - **Offline**: Changes saved locally and queued for sync
  - **Reconnect**: Pending changes sync automatically within seconds
  - **No Manual Sync Required**: Works like Google Docs, Notion, etc.

- **📱 Offline-First**: Full functionality without internet connection
  - All data stored locally first using Isar
  - Real-time UI updates from local database
  - Seamless transition between online/offline modes

- **📊 Project Management**: Complete CRUD operations
  - Create, edit, and delete projects
  - Track budget, dates, and status
  - Beautiful Material Design 3 UI

- **✅ Task Management**: Organize work within projects
  - Manage tasks with due dates
  - Link tasks to projects
  - Real-time task updates

- **⚡ Smart Conflict Resolution**:
  - Last-Write-Wins (LWW) for edits based on timestamps
  - **Deletion-First**: Deletions always take priority over edits
  - Prevents accidental data restoration

- **🏗️ Clean Architecture**: Production-ready code structure
  - Domain, Data, and Presentation layers
  - Dependency injection via Riverpod
  - Testable and maintainable

- **🔌 Connectivity-Aware**: Intelligent network handling
  - Real-time connectivity monitoring
  - Graceful degradation when offline
  - Visual indicators for online/offline status

## 🏗️ Architecture

The app follows clean architecture with a hybrid repository pattern for auto-sync:

```
lib/
├── core/
│   └── services/          # Core services
│       ├── connectivity_service.dart    # Network monitoring
│       └── sync_orchestrator.dart       # Background sync
├── domain/
│   ├── entities/          # Business entities (Project, Task)
│   └── repositories/      # Repository interfaces
├── data/
│   ├── models/            # Data models with Isar & Appwrite mappings
│   ├── datasources/       # Data sources
│   │   ├── local/         # Isar (local database)
│   │   └── remote/        # Appwrite TablesDB (cloud)
│   └── repositories/      # Repository implementations
│       ├── *_hybrid_repository.dart    # Auto-sync repositories (NEW!)
│       └── *_repository_impl.dart      # Legacy local/remote repos
└── presentation/
    ├── providers/         # Riverpod providers & state
    └── screens/           # UI screens (Projects, Tasks, Forms)
```

### Hybrid Repository Pattern

The **Hybrid Repository** automatically routes operations based on connectivity:

```
User Action → Hybrid Repository
              ↓
       Check Connectivity
          ↙        ↘
      Online      Offline
        ↓            ↓
     Remote       Local
   + Cache     (needsSync)
        ↓            ↓
     Local DB ← ─ ─ ┘
        ↓
    UI Stream
```

**Benefits:**
- No manual sync button clicks
- Automatic fallback on network errors
- Local-first UI for instant feedback
- Smart caching strategy

## 🛠️ Tech Stack

- **Flutter 3.x**: Cross-platform UI framework
- **Isar Community 3.3.0-dev.3**: Fast local NoSQL database with real-time queries
- **Appwrite 20.3.0**: Backend as a Service (using TablesDB API)
- **Riverpod 3.0**: Modern state management and dependency injection
- **Connectivity Plus**: Real-time network status monitoring
- **UUID**: Unique identifier generation
- **Flutter Dotenv**: Environment configuration

## 🚀 Quick Start

See [QUICK_START.md](QUICK_START.md) for a quick overview of the auto-sync feature.

### 1. Prerequisites

- Flutter 3.x or higher
- Dart 3.0 or higher
- FVM (recommended for version management)
- An Appwrite account (free at [cloud.appwrite.io](https://cloud.appwrite.io))

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Isar Database Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configure Appwrite Backend

**Option A: Use the Setup Script (Recommended)**
See [SETUP.md](SETUP.md) for detailed Appwrite configuration instructions.

**Option B: Manual Setup**

1. Create an Appwrite account at [cloud.appwrite.io](https://cloud.appwrite.io)
2. Create a new project
3. Create a database
4. Create two tables (collections):

**Projects Table:**
```
Table ID: projects
Attributes:
- projectName (string, 128 chars)
- description (string, 1000 chars)
- startDate (datetime, optional)
- endDate (datetime, optional)
- budget (double)
- status (string, 50 chars)
- createdAt (datetime, required)
- updatedAt (datetime, required)
- isDeleted (boolean, default: false)
```

**Tasks Table:**
```
Table ID: tasks
Attributes:
- name (string, 128 chars)
- description (string, 1000 chars)
- dueDate (datetime, optional)
- projectId (string, 36 chars)
- createdAt (datetime, required)
- updatedAt (datetime, required)
- isDeleted (boolean, default: false)
```

### 5. Configure Environment

1. Create `environments/.env.local`:

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id_here
APPWRITE_DATABASE_ID=your_database_id_here
APPWRITE_PROJECTS_COLLECTION_ID=projects
APPWRITE_TASKS_COLLECTION_ID=tasks
```

2. Get your IDs from Appwrite Console → Settings

### 6. Run the App

```bash
# Using FVM (recommended)
fvm flutter run

# Or standard Flutter
flutter run

# For specific environment
flutter run --dart-define=ENV=local
```

That's it! The app will automatically handle sync based on connectivity. ✨

## 📖 How Auto-Sync Works

### When You're ONLINE 🟢

```
User creates/edits/deletes → Hybrid Repository
                              ↓
                      Try write to Remote (Appwrite)
                              ↓
                     Success? → Update Local Cache
                              ↓
                         UI Updates Instantly
```

**Result:** Changes sync to cloud immediately. Available on all devices.

### When You're OFFLINE 🔴

```
User creates/edits/deletes → Hybrid Repository
                              ↓
                      Save to Local (Isar)
                              ↓
                      Mark needsSync = true
                              ↓
                         UI Updates Instantly
```

**Result:** Changes saved locally. Will sync when back online.

### When You RECONNECT 🔄

```
Connectivity Restored
        ↓
Sync Orchestrator Triggered
        ↓
1. Push pending local changes (needsSync=true)
2. Pull remote changes from other devices
3. Apply smart conflict resolution
4. Update local cache
        ↓
All Devices In Sync!
```

**Timing:** Usually syncs within 1-5 seconds of reconnection.

### Smart Conflict Resolution

**For Edits - Last Write Wins (LWW):**
```
Device A edits at 10:00 AM → updatedAt: 10:00
Device B edits at 11:00 AM → updatedAt: 11:00
Sync → Device B wins (newer timestamp)
```

**For Deletions - Deletion Always Wins:**
```
Device A deletes at 10:00 AM → isDeleted: true
Device B edits at 11:00 AM → isDeleted: false
Sync → Device A wins (deletion takes priority)
```

**Why?** Deletions are intentional user actions that should take precedence over any edit, preventing accidental data restoration.

### Preserving Pending Changes

When fetching from remote, the hybrid repository:
1. Checks if local has `needsSync: true`
2. If yes, keeps local version (don't overwrite pending changes)
3. If no, updates with remote version
4. Sync orchestrator then pushes pending changes

This ensures offline changes are never lost when going back online.

## 🔑 Key Components

### Hybrid Repositories (Auto-Sync Layer)
- **`ProjectHybridRepository`**: Routes project operations based on connectivity
- **`TaskHybridRepository`**: Routes task operations based on connectivity
- Automatically writes to remote when online
- Falls back to local when offline
- Preserves pending changes (`needsSync: true`)

### Sync Orchestrator (Background Sync)
- Monitors connectivity changes via `ConnectivityService`
- Triggers sync immediately on reconnection
- Performs periodic sync every 5 minutes when online
- Implements deletion-first + LWW conflict resolution
- Manages sync status (idle, syncing, success, error)

### Data Sources
**Local (Isar):**
- `IsarLocalDatasource`: Base Isar implementation
- `ProjectLocalDatasource`: Project-specific operations
- `TaskLocalDatasource`: Task-specific operations
- Fast NoSQL database with real-time queries
- Watches for data changes via streams

**Remote (Appwrite TablesDB):**
- `AppwriteRemoteDatasource`: Base Appwrite client setup
- `AppwriteProjectRemoteDatasource`: Project cloud operations
- `AppwriteTaskRemoteDatasource`: Task cloud operations
- Uses latest TablesDB API (not deprecated Databases API)
- Easily swappable with Supabase, Firebase, etc.

### Services
- **`ConnectivityService`**: Real-time network monitoring
- **`SyncOrchestrator`**: Coordinates sync operations
- Both initialized automatically via Riverpod

## 📊 Project Status

### ✅ Completed Features

- **Auto-Sync Architecture**: Zero-config automatic synchronization
- **Hybrid Repository Pattern**: Smart online/offline routing
- **Deletion-First Sync**: Deletions always take priority
- **Appwrite TablesDB Integration**: Using latest non-deprecated API
- **Complete CRUD**: Projects and tasks fully functional
- **Conflict Resolution**: LWW for edits, deletion-first for removals
- **Real-time UI**: Local-first with instant updates
- **Connectivity Monitoring**: Live online/offline indicators
- **Clean Architecture**: Production-ready code structure
- **State Management**: Riverpod with dependency injection
- **Error Handling**: Graceful fallbacks and user feedback
- **Material Design 3**: Beautiful, modern UI

### 🧪 Testing Checklist

- ✅ Create/edit/delete projects while online → Syncs immediately
- ✅ Create/edit/delete projects while offline → Syncs on reconnect
- ✅ Delete project offline → Deletion syncs correctly (not restored)
- ✅ Multi-device scenario → Changes merge correctly
- ✅ Network errors → Graceful fallback to local
- ✅ Timestamp conflicts → LWW resolution works
- ✅ Flutter analyze → No issues or deprecated members

### 🚀 Future Enhancements

**Phase 1 - Core Features:**
- [ ] User authentication and authorization
- [ ] Multi-user collaboration
- [ ] Real-time sync using Appwrite Realtime API
- [ ] Pagination for large datasets

**Phase 2 - Extended Features:**
- [ ] File attachments and media
- [ ] Advanced search and filtering
- [ ] Data export (CSV, PDF)
- [ ] Analytics and reports
- [ ] Notifications and reminders

**Phase 3 - Polish:**
- [ ] Dark mode
- [ ] Offline indicators on items
- [ ] Sync queue UI (show pending changes)
- [ ] Retry mechanism with exponential backoff
- [ ] Data compression for faster sync

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Quick reference guide
- **[AUTO_SYNC_GUIDE.md](AUTO_SYNC_GUIDE.md)** - Complete technical architecture
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - What changed and why
- **[CHANGES.md](CHANGES.md)** - Detailed change log
- **[SETUP.md](SETUP.md)** - Appwrite configuration guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture details

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Code Analysis
```bash
# Using FVM
fvm flutter analyze

# Standard Flutter
flutter analyze
```

## 🐛 Known Issues

None! All major issues have been resolved:
- ✅ Offline deletions now sync correctly
- ✅ No deprecated API warnings
- ✅ Pending changes preserved during reconnection

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- **Isar** - Fast and lightweight NoSQL database
- **Appwrite** - Open-source Backend as a Service
- **Riverpod** - Modern Flutter state management
- **Flutter Team** - Amazing framework

## 📧 Support

For questions or issues:
- Check the [documentation](QUICK_START.md)
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- Open an issue on GitHub

---

**Built with ❤️ using Flutter and Offline-First principles**

*Last Updated: November 2025*
