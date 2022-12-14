import ballerina/sql;
import ballerinax/mysql;
import ballerina/persist;

public client class DonorClient {
    *persist:AbstractPersistClient;

    private final string entityName = "Donor";
    private final sql:ParameterizedQuery tableName = `Donor`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        donorId: {columnName: "donorId", 'type: int, autoGenerated: true},
        orgName: {columnName: "orgName", 'type: string},
        orgLink: {columnName: "orgLink", 'type: string},
        email: {columnName: "email", 'type: string},
        phone: {columnName: "phone", 'type: int},
        quotation: {columnName: "quotation", 'type: Quote}
    };
    private string[] keyFields = ["donorId"];

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata);
    }

    remote function create(Donor value) returns Donor|persist:Error {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);
        return {donorId: <int>result.lastInsertId, orgName: value.orgName, orgLink: value.orgLink, email: value.email, phone: value.phone, quotation: value.quotation};
    }

    remote function readByKey(int key) returns Donor|persist:Error {
        return <Donor>check self.persistClient.runReadByKeyQuery(Donor, key);
    }

    remote function read() returns stream<Donor, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(Donor);
        if result is persist:Error {
            return new stream<Donor, persist:Error?>(new DonorStream((), result));
        } else {
            return new stream<Donor, persist:Error?>(new DonorStream(result));
        }
    }

    remote function execute(sql:ParameterizedQuery filterClause) returns stream<Donor, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runExecuteQuery(filterClause, Donor);
        if result is persist:Error {
            return new stream<Donor, persist:Error?>(new DonorStream((), result));
        } else {
            return new stream<Donor, persist:Error?>(new DonorStream(result));
        }
    }

    remote function update(Donor value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
    }

    remote function delete(Donor value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(Donor donor) returns boolean|persist:Error {
        Donor|persist:Error result = self->readByKey(donor.donorId);
        if result is Donor {
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

public class DonorStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|Donor value;|}|persist:Error? {
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
                record {|Donor value;|} nextRecord = {value: <Donor>streamValue.value};
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

