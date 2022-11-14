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

service /donors on new http:Listener(8087) {

    final clients:DonorClient donorClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload Donor donor) returns Donor|error {
        return self.donorClient->create(donor);
    }

    resource function get .() returns Donor[]|error? {
        return from Donor donor in self.donorClient->read()
               select donor;
    }

    resource function get [int donorId]() returns Donor|error {
        return self.donorClient->readByKey(donorId);
    }

    resource function put .(@http:Payload Donor donor) returns Donor|error {
        check self.donorClient->update(donor);
        return donor;
    }

    resource function delete [int donorId]() returns error? {
        Donor donor = check self.donorClient->readByKey(donorId);
        check self.donorClient->delete(donor);
    }
}
