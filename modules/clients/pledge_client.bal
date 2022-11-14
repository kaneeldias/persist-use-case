import ballerina/sql;
import ballerinax/mysql;
import ballerina/persist;

public client class PledgeClient {

    private final string entityName = "Pledge";
    private final sql:ParameterizedQuery tableName = `Pledge`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        pledgeId: {columnName: "pledgeId", 'type: int, autoGenerated: true},
        amount: {columnName: "amount", 'type: int},
        status: {columnName: "status", 'type: string},
        "package.packageId": {columnName: "packageId", 'type: int, relation: {entityName: "package", refTable: "AidPackage", refField: "packageId"}},
        "package.description": {'type: int, relation: {entityName: "package", refTable: "AidPackage", refField: "description"}},
        "package.name": {'type: string, relation: {entityName: "package", refTable: "AidPackage", refField: "name"}},
        "package.status": {'type: string, relation: {entityName: "package", refTable: "AidPackage", refField: "status"}},
        "donor.donorId": {columnName: "donorId", 'type: int, relation: {entityName: "donor", refTable: "Donor", refField: "donorId"}},
        "donor.orgName": {'type: string, relation: {entityName: "donor", refTable: "Donor", refField: "orgName"}},
        "donor.orgLink": {'type: string, relation: {entityName: "donor", refTable: "Donor", refField: "orgLink"}},
        "donor.email": {'type: string, relation: {entityName: "donor", refTable: "Donor", refField: "email"}},
        "donor.phone": {'type: int, relation: {entityName: "donor", refTable: "Donor", refField: "phone"}}
    };
    private string[] keyFields = ["pledgeId"];

    private final map<persist:JoinMetadata> joinMetadata = {
        package: {entity: AidPackage, fieldName: "package", refTable: "AidPackage", refFields: ["packageId"], joinColumns: ["packageId"]},
        donor: {entity: Donor, fieldName: "donor", refTable: "Donor", refFields: ["donorId"], joinColumns: ["donorId"]}
    };

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata, self.joinMetadata);
    }

    remote function create(Pledge value) returns Pledge|persist:Error {
        if value.package is AidPackage {
            AidPackageClient aidPackageClient = check new AidPackageClient();
            boolean exists = check aidPackageClient->exists(<AidPackage>value.package);
            if !exists {
                value.package = check aidPackageClient->create(<AidPackage>value.package);
            }
        }
        if value.donor is Donor {
            DonorClient donorClient = check new DonorClient();
            boolean exists = check donorClient->exists(<Donor>value.donor);
            if !exists {
                value.donor = check donorClient->create(<Donor>value.donor);
            }
        }
        _ = check self.persistClient.runInsertQuery(value);
        return value;
    }

    remote function readByKey(int key, PledgeRelations[] include = []) returns Pledge|persist:Error {
        return <Pledge>check self.persistClient.runReadByKeyQuery(Pledge, key, include);
    }

    remote function read(PledgeRelations[] include = []) returns stream<Pledge, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(Pledge, include);
        if result is persist:Error {
            return new stream<Pledge, persist:Error?>(new PledgeStream((), result));
        } else {
            return new stream<Pledge, persist:Error?>(new PledgeStream(result));
        }
    }

    remote function execute(sql:ParameterizedQuery filterClause) returns stream<Pledge, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runExecuteQuery(filterClause, Pledge);
        if result is persist:Error {
            return new stream<Pledge, persist:Error?>(new PledgeStream((), result));
        } else {
            return new stream<Pledge, persist:Error?>(new PledgeStream(result));
        }
    }

    remote function update(Pledge value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
        if value.package is record {} {
            AidPackage aidPackageEntity = <AidPackage>value.package;
            AidPackageClient aidPackageClient = check new AidPackageClient();
            check aidPackageClient->update(aidPackageEntity);
        }
        if value.donor is record {} {
            Donor donorEntity = <Donor>value.donor;
            DonorClient donorClient = check new DonorClient();
            check donorClient->update(donorEntity);
        }
    }

    remote function delete(Pledge value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(Pledge pledge) returns boolean|persist:Error {
        Pledge|persist:Error result = self->readByKey(pledge.pledgeId);
        if result is Pledge {
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

public enum PledgeRelations {
    AidPackageEntity = "package", DonorEntity = "donor"
}

public class PledgeStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|Pledge value;|}|persist:Error? {
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
                record {|Pledge value;|} nextRecord = {value: <Pledge>streamValue.value};
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
