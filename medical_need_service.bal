import red_cross2.clients;
import ballerina/http;

service /medicalNeeds on new http:Listener(8082) {

    final clients:MedicalNeedClient medicalNeedClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload MedicalNeed medicalNeed) returns MedicalNeed|error {
        return self.medicalNeedClient->create(medicalNeed);
    }

    resource function get .() returns MedicalNeed[]|error? {
        return from MedicalNeed medicalNeed in self.medicalNeedClient->read(["item"])
               select medicalNeed;
    }

    resource function get [int medicalNeedId]() returns MedicalNeed|error {
        return self.medicalNeedClient->readByKey(medicalNeedId, ["item"]);
    }

    resource function put .(@http:Payload MedicalNeed medicalNeed) returns MedicalNeed|error {
        check self.medicalNeedClient->update(medicalNeed);
        return medicalNeed;
    }

    resource function delete [int medicalNeedId]() returns error? {
        MedicalNeed medicalNeed = check self.medicalNeedClient->readByKey(medicalNeedId);
        check self.medicalNeedClient->delete(medicalNeed);
    }
}
