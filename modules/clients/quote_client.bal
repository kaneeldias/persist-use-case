import ballerina/sql;
import ballerinax/mysql;
import ballerina/persist;

public client class QuoteClient {

    private final string entityName = "Quote";
    private final sql:ParameterizedQuery tableName = `Quote`;

    private final map<persist:FieldMetadata> fieldMetadata = {
        quoteId: {columnName: "quoteId", 'type: int, autoGenerated: true},
        maxQuantity: {columnName: "maxQuantity", 'type: int},
        period: {columnName: "period", 'type: int},
        brandName: {columnName: "brandName", 'type: string},
        unitPrice: {columnName: "unitPrice", 'type: int},
        expiryDate: {columnName: "expiryDate", 'type: int},
        regulatoryInfo: {columnName: "regulatoryInfo", 'type: string},
        "supplier.supplierId": {columnName: "supplierId", 'type: int, relation: {entityName: "supplier", refTable: "SupplierInfo", refField: "supplierId"}},
        "supplier.name": {'type: string, relation: {entityName: "supplier", refTable: "SupplierInfo", refField: "name"}},
        "supplier.shortName": {'type: string, relation: {entityName: "supplier", refTable: "SupplierInfo", refField: "shortName"}},
        "supplier.email": {'type: string, relation: {entityName: "supplier", refTable: "SupplierInfo", refField: "email"}},
        "supplier.phoneNumber": {'type: string, relation: {entityName: "supplier", refTable: "SupplierInfo", refField: "phoneNumber"}},
        "item.itemId": {columnName: "itemId", 'type: int, relation: {entityName: "item", refTable: "MedicalItem", refField: "itemId"}},
        "item.name": {'type: string, relation: {entityName: "item", refTable: "MedicalItem", refField: "name"}},
        "item.'type": {'type: string, relation: {entityName: "item", refTable: "MedicalItem", refField: "'type"}},
        "item.unit": {'type: string, relation: {entityName: "item", refTable: "MedicalItem", refField: "unit"}}
    };
    private string[] keyFields = ["quoteId"];

    private final map<persist:JoinMetadata> joinMetadata = {
        supplier: {entity: SupplierInfo, fieldName: "supplier", refTable: "SupplierInfo", refFields: ["supplierId"], joinColumns: ["supplierId"]},
        item: {entity: MedicalItem, fieldName: "item", refTable: "MedicalItem", refFields: ["itemId"], joinColumns: ["itemId"]}
    };

    private persist:SQLClient persistClient;

    public function init() returns persist:Error? {
        mysql:Client|sql:Error dbClient = new (host = host, user = user, password = password, database = database, port = port);
        if dbClient is sql:Error {
            return <persist:Error>error(dbClient.message());
        }
        self.persistClient = check new (dbClient, self.entityName, self.tableName, self.keyFields, self.fieldMetadata, self.joinMetadata);
    }

    remote function create(Quote value) returns Quote|persist:Error {
        if value.supplier is SupplierInfo {
            SupplierInfoClient supplierInfoClient = check new SupplierInfoClient();
            boolean exists = check supplierInfoClient->exists(<SupplierInfo>value.supplier);
            if !exists {
                value.supplier = check supplierInfoClient->create(<SupplierInfo>value.supplier);
            }
        }
        if value.item is MedicalItem {
            MedicalItemClient medicalItemClient = check new MedicalItemClient();
            boolean exists = check medicalItemClient->exists(<MedicalItem>value.item);
            if !exists {
                value.item = check medicalItemClient->create(<MedicalItem>value.item);
            }
        }
        _ = check self.persistClient.runInsertQuery(value);
        return value;
    }

    remote function readByKey(int key, QuoteRelations[] include = []) returns Quote|persist:Error {
        return <Quote>check self.persistClient.runReadByKeyQuery(Quote, key, include);
    }

    remote function read(QuoteRelations[] include = []) returns stream<Quote, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runReadQuery(Quote, include);
        if result is persist:Error {
            return new stream<Quote, persist:Error?>(new QuoteStream((), result));
        } else {
            return new stream<Quote, persist:Error?>(new QuoteStream(result));
        }
    }

    remote function execute(sql:ParameterizedQuery filterClause) returns stream<Quote, persist:Error?> {
        stream<anydata, sql:Error?>|persist:Error result = self.persistClient.runExecuteQuery(filterClause, Quote);
        if result is persist:Error {
            return new stream<Quote, persist:Error?>(new QuoteStream((), result));
        } else {
            return new stream<Quote, persist:Error?>(new QuoteStream(result));
        }
    }

    remote function update(Quote value) returns persist:Error? {
        _ = check self.persistClient.runUpdateQuery(value);
        if value.supplier is record {} {
            SupplierInfo supplierInfoEntity = <SupplierInfo>value.supplier;
            SupplierInfoClient supplierInfoClient = check new SupplierInfoClient();
            check supplierInfoClient->update(supplierInfoEntity);
        }
        if value.item is record {} {
            MedicalItem medicalItemEntity = <MedicalItem>value.item;
            MedicalItemClient medicalItemClient = check new MedicalItemClient();
            check medicalItemClient->update(medicalItemEntity);
        }
    }

    remote function delete(Quote value) returns persist:Error? {
        _ = check self.persistClient.runDeleteQuery(value);
    }

    remote function exists(Quote quote) returns boolean|persist:Error {
        Quote|persist:Error result = self->readByKey(quote.quoteId);
        if result is Quote {
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

public enum QuoteRelations {
    SupplierInfoEntity = "supplier", MedicalItemEntity = "item"
}

public class QuoteStream {

    private stream<anydata, sql:Error?>? anydataStream;
    private persist:Error? err;

    public isolated function init(stream<anydata, sql:Error?>? anydataStream, persist:Error? err = ()) {
        self.anydataStream = anydataStream;
        self.err = err;
    }

    public isolated function next() returns record {|Quote value;|}|persist:Error? {
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
                record {|Quote value;|} nextRecord = {value: <Quote>streamValue.value};
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
