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
