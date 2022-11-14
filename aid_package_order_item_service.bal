import red_cross2.clients;
import ballerina/http;

service /aidPackageOrderItem on new http:Listener(8086) {

    final clients:AidPackageOrderItemClient aidPackageOrderItemClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload AidPackageOrderItem aidPackageOrderItem) returns AidPackageOrderItem|error {
        return self.aidPackageOrderItemClient->create(aidPackageOrderItem);
    }

    resource function get .() returns AidPackageOrderItem[]|error? {
        return from AidPackageOrderItem aidPackageOrderItem in self.aidPackageOrderItemClient->read(["package", "medicalNeed", "supplier"])
               select aidPackageOrderItem;
    }

    resource function get [int aidPackageOrderItemId]() returns AidPackageOrderItem|error {
        return self.aidPackageOrderItemClient->readByKey(aidPackageOrderItemId, ["package", "medicalNeed", "supplier"]);
    }

    resource function put .(@http:Payload AidPackageOrderItem aidPackageOrderItem) returns AidPackageOrderItem|error {
        check self.aidPackageOrderItemClient->update(aidPackageOrderItem);
        return aidPackageOrderItem;
    }

    resource function delete [int aidPackageOrderItemId]() returns error? {
        AidPackageOrderItem aidPackageOrderItem = check self.aidPackageOrderItemClient->readByKey(aidPackageOrderItemId);
        check self.aidPackageOrderItemClient->delete(aidPackageOrderItem);
    }
}
