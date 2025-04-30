import ballerina/task;
import ballerina/io;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerina/lang.runtime;

configurable task:PostgresqlConfig databaseConfig = ?;
configurable int livenessCheckInterval = ?;
configurable int heartbeatFrequency = ?;
configurable string taskId = ?;
configurable string groupId = ?;

postgresql:Client dbClient = check new (username = databaseConfig.user, password = databaseConfig.password, database = "testdb");

task:JobId result = check task:scheduleJobRecurByFrequency(
    job = new Job(),
    interval = 15,
    maxCount = 5,
    warmBackupConfig = {
        databaseConfig,
        livenessCheckInterval,
        taskId,
        groupId,
        heartbeatFrequency
    }
);

public function main() returns error? {
    io:println("Job scheduled with ID: ", result);
    runtime:sleep(140);
}

class Job {
    *task:Job;

    public function execute() {
        do {
            sql:ExecutionResult executeResult = check dbClient->execute(`INSERT INTO orders (message) VALUES ('ordered')`);
            io:println("Query executed in Orders table: ", executeResult);
        } on fail error err {
            io:println("Error occurred while executing the job: ", err);
        }
    }
}
