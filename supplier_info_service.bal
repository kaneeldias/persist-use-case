import red_cross2.clients;
import ballerina/http;

service /supplierInfo on new http:Listener(8084) {

    final clients:SupplierInfoClient supplierInfoClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload SupplierInfo supplierInfo) returns SupplierInfo|error {
        return self.supplierInfoClient->create(supplierInfo);
    }

    resource function get .() returns SupplierInfo[]|error? {
        return from SupplierInfo supplierInfo in self.supplierInfoClient->read()
               select supplierInfo;
    }

    resource function get [int supplierInfoId]() returns SupplierInfo|error {
        return self.supplierInfoClient->readByKey(supplierInfoId);
    }

    resource function put .(@http:Payload SupplierInfo supplierInfo) returns SupplierInfo|error {
        check self.supplierInfoClient->update(supplierInfo);
        return supplierInfo;
    }

    resource function delete [int supplierInfoId]() returns error? {
        SupplierInfo supplierInfo = check self.supplierInfoClient->readByKey(supplierInfoId);
        check self.supplierInfoClient->delete(supplierInfo);
    }
}
