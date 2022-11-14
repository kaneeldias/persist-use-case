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

service /supplierInfo on new http:Listener(8084) {

    final clients:SupplierInfoClient supplierInfoClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload SupplierInfo supplierInfo) returns SupplierInfo|error {
        return self.supplierInfoClient->create(supplierInfo);
    }

    resource function get .() returns SupplierInfo[]|error? {
        return from SupplierInfo supplierInfo in self.supplierInfoClient->read()
               select supplierInfo;
    }

    resource function get [int supplierInfoId]() returns SupplierInfo|error {
        return self.supplierInfoClient->readByKey(supplierInfoId);
    }

    resource function put .(@http:Payload SupplierInfo supplierInfo) returns SupplierInfo|error {
        check self.supplierInfoClient->update(supplierInfo);
        return supplierInfo;
    }

    resource function delete [int supplierInfoId]() returns error? {
        SupplierInfo supplierInfo = check self.supplierInfoClient->readByKey(supplierInfoId);
        check self.supplierInfoClient->delete(supplierInfo);
    }
}
