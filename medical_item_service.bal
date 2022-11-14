import red_cross2.clients;
import ballerina/http;

service /medicalItems on new http:Listener(8082) {

    final clients:MedicalItemClient medicalItemClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload MedicalItem medicalItem) returns MedicalItem|error {
        return self.medicalItemClient->create(medicalItem);
    }

    resource function get .() returns MedicalItem[]|error? {
        return from MedicalItem medicalItem in self.medicalItemClient->read()
               select medicalItem;
    }

    resource function get [int medicalItemId]() returns MedicalItem|error {
        return self.medicalItemClient->readByKey(medicalItemId);
    }

    resource function put .(@http:Payload MedicalItem medicalItem) returns MedicalItem|error {
        check self.medicalItemClient->update(medicalItem);
        return medicalItem;
    }

    resource function delete [int medicalItemId]() returns error? {
        MedicalItem medicalItem = check self.medicalItemClient->readByKey(medicalItemId);
        check self.medicalItemClient->delete(medicalItem);
    }
}
