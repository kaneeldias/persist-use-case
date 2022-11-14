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
