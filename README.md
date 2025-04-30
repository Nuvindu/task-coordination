# Task Coordination in Ballerina

## Overview

This repository demonstrates the task coordination capabilities in Ballerina, designed for distributed systems where high availability is necessary. The coordination mechanism ensures that when tasks are running on multiple nodes, only one node is active while others remain on standby. If the active node fails, one of the standby nodes automatically takes over, maintaining system availability.

This repository implements an RDBMS-based coordination system that handles system availability across multiple nodes, improving the reliability and uptime of distributed applications.

## Design

The task coordination system follows a warm backup approach where,

* Multiple nodes run the same program logic on separate tasks
* One node is designated as token-bearer and execute the program logic
* Other nodes act as watchdogs by monitoring the status of the token-bearer node
* If the active node fails, one of the candidate node takes over automatically

## Configurations

The task coordination system can be configured using the `WarmBackupConfig` record. This handles how each node participates in coordination, how frequently it checks for liveness, updates its status, and connects to the coordination database.

```ballerina
public type WarmBackupConfig record {
    DatabaseConfig databaseConfig = {};
    int livenessCheckInterval = 30;
    string taskId;
    string groupId;
    int heartbeatFrequency = 1;
};

public type DatabaseConfig MysqlConfig|PostgresqlConfig;
```

### Configuration Parameters

| Parameter | Description |
|-----------|-------------|
| **databaseConfig** | Database configurations for task coordination |
| **livenessCheckInterval** | Interval (in seconds) to check the liveness of the active node |
| **taskId** | Unique identifier for the current node |
| **groupId** | Identifier for the group of nodes coordinating the task |
| **heartbeatFrequency** | Interval (in seconds) for the node to update its heartbeat |

### Database Configuration

The `databaseConfig` can be either MySQL or PostgreSQL. This is defined using a union type as `DatabaseConfig`. Users can choose either `task:MysqlConfig` or `task:PostgresqlConfig` based on their preferred database.

**For PostgreSQL:**

```ballerina
type PostgresqlConfig record {
    string host;
    int port;
    string user;
    string password;
    string database;
};
```

**For MySQL:**

```ballerina
type MysqlConfig record {
    string host;
    int port;
    string user;
    string password;
    string database;
};
```

## Getting Started

### Setup

1. Clone this repository.

   ```bash
   git clone https://github.com/Nuvindu/task-coordination.git
   cd task-coordination
   ```

2. Start the PostgreSQL server.

   ```bash
   docker compose up
   ```

3. Configure your application by updating the `Config.toml` file.

   ```toml
   taskId = "add-unique-task"
   groupId = "task-group-01"
   heartbeatFrequency = 1
   livenessCheckInterval = 6

   [databaseConfig]
    host = "localhost"
    user = "root"
    password = "password"
    port = 5432
    database = "testdb"
   ```

4. Run the application.

   ```bash
   bal run
   ```

### Process

1. Run the application on two different VMs or instances
2. Make sure to set a unique `taskId` for each instance
3. Observe that only one node is processing tasks
4. Stop or disconnect the token bearer node
5. Observe that the task in the candidate node detects the failure and takes over automatically
