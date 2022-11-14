import red_cross2.clients;
import ballerina/http;

service /requirements on new http:Listener(8081) {

    final clients:RequirementListClient requirementListClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload RequirementList requirementList) returns RequirementList|error {
        return self.requirementListClient->create(requirementList);
    }

    resource function get .() returns RequirementList[]|error? {
        return from RequirementList requirementList in self.requirementListClient->read()
               select requirementList;
    }

    resource function get [int requirementId]() returns RequirementList|error {
        return self.requirementListClient->readByKey(requirementId);
    }

    resource function put .(@http:Payload RequirementList requirementList) returns RequirementList|error {
        check self.requirementListClient->update(requirementList);
        return requirementList;
    }

    resource function delete [int requirementListId]() returns error? {
        RequirementList requirementList = check self.requirementListClient->readByKey(requirementListId);
        check self.requirementListClient->delete(requirementList);
    }
}
