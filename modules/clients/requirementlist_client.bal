import ballerina/sql;
import ballerinax/mysql;
import ballerina/persist;

public client class RequirementListClient {

    private final string entityName = "RequirementList";
    private final sql:ParameterizedQuery tableName = `RequirementList`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        requirementId: {columnName: "requirementId", 'type: int},
        name: {columnName: "name", 'type: string}
    };
    private string[] keyFields = ["requirementId"];

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata);
    }

    remote function create(RequirementList value) returns RequirementList|persist:Error {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);
        if result.lastInsertId is () {
            return value;
        }
        return {requirementId: <int>result.lastInsertId, name: value.name};
    }

    remote function readByKey(int key) returns RequirementList|persist:Error {
        return <RequirementList>check self.persistClient.runReadByKeyQuery(RequirementList, key);
    }

    remote function read() returns stream<RequirementList, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(RequirementList);
        if result is persist:Error {
            return new stream<RequirementList, persist:Error?>(new RequirementListStream((), result));
        } else {
            return new stream<RequirementList, persist:Error?>(new RequirementListStream(result));
        }
    }

    remote function execute(sql:ParameterizedQuery filterClause) returns stream<RequirementList, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runExecuteQuery(filterClause, RequirementList);
        if result is persist:Error {
            return new stream<RequirementList, persist:Error?>(new RequirementListStream((), result));
        } else {
            return new stream<RequirementList, persist:Error?>(new RequirementListStream(result));
        }
    }

    remote function update(RequirementList value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
    }

    remote function delete(RequirementList value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(RequirementList requirementList) returns boolean|persist:Error {
        RequirementList|persist:Error result = self->readByKey(requirementList.requirementId);
        if result is RequirementList {
            return true;
        } else if result is persist:InvalidKeyError {
            return false;
        } else {
            return result;
        }
    }

    public function close() returns persist:Error? {
        return self.persistClient.close();
    }
}

public class RequirementListStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|RequirementList value;|}|persist:Error? {
        if self.err is persist:Error {
            return <persist:Error>self.err;
        } else if self.anydataStream is stream<anydata, sql:Error?> {
            var anydataStream = <stream<anydata, sql:Error?>>self.anydataStream;
            var streamValue = anydataStream.next();
            if streamValue is () {
                return streamValue;
            } else if (streamValue is sql:Error) {
                return <persist:Error>error(streamValue.message());
            } else {
                record {|RequirementList value;|} nextRecord = {value: <RequirementList>streamValue.value};
                return nextRecord;
            }
        } else {
            return ();
        }
    }

    public isolated function close() returns persist:Error? {
        if self.anydataStream is stream<anydata, sql:Error?> {
            var anydataStream = <stream<anydata, sql:Error?>>self.anydataStream;
            sql:Error? e = anydataStream.close();
            if e is sql:Error {
                return <persist:Error>error(e.message());
            }
        }
    }
}

