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

import use_case.clients;
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
