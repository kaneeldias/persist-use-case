import red_cross2.clients;
import ballerina/http;

service /donors on new http:Listener(8080) {

    final clients:DonorClient donorClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload Donor donor) returns Donor|error {
        return self.donorClient->create(donor);
    }

    resource function get .() returns Donor[]|error? {
        return from Donor donor in self.donorClient->read()
               select donor;
    }

    resource function get [int donorId]() returns Donor|error {
        return self.donorClient->readByKey(donorId);
    }

    resource function put .(@http:Payload Donor donor) returns Donor|error {
        check self.donorClient->update(donor);
        return donor;
    }

    resource function delete [int donorId]() returns error? {
        Donor donor = check self.donorClient->readByKey(donorId);
        check self.donorClient->delete(donor);
    }
}
