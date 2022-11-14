import red_cross2.clients;
import ballerina/http;

service /pledge on new http:Listener(8087) {

    final clients:PledgeClient pledgeClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload Pledge pledge) returns Pledge|error {
        return self.pledgeClient->create(pledge);
    }

    resource function get .() returns Pledge[]|error? {
        return from Pledge pledge in self.pledgeClient->read(["package", "donor"])
               select pledge;
    }

    resource function get [int pledgeId]() returns Pledge|error {
        return self.pledgeClient->readByKey(pledgeId, ["package", "donor"]);
    }

    resource function put .(@http:Payload Pledge pledge) returns Pledge|error {
        check self.pledgeClient->update(pledge);
        return pledge;
    }

    resource function delete [int pledgeId]() returns error? {
        Pledge pledge = check self.pledgeClient->readByKey(pledgeId);
        check self.pledgeClient->delete(pledge);
    }
}
