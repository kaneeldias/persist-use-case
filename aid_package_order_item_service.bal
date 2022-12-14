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
