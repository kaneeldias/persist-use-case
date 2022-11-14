// Copyright (c) 2022 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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
