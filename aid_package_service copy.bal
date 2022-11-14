import red_cross2.clients;
import ballerina/http;

service /aidPackage on new http:Listener(8085) {

    final clients:AidPackageClient aidPackageClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload AidPackage aidPackage) returns AidPackage|error {
        return self.aidPackageClient->create(aidPackage);
    }

    resource function get .() returns AidPackage[]|error? {
        return from AidPackage aidPackage in self.aidPackageClient->read(["supplier"])
               select aidPackage;
    }

    resource function get [int aidPackageId]() returns AidPackage|error {
        return self.aidPackageClient->readByKey(aidPackageId, ["supplier"]);
    }

    resource function put .(@http:Payload AidPackage aidPackage) returns AidPackage|error {
        check self.aidPackageClient->update(aidPackage);
        return aidPackage;
    }

    resource function delete [int aidPackageId]() returns error? {
        AidPackage aidPackage = check self.aidPackageClient->readByKey(aidPackageId);
        check self.aidPackageClient->delete(aidPackage);
    }
}
