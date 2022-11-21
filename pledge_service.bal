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

service /pledge on new http:Listener(8087) {

    final clients:PledgeClient pledgeClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload Pledge pledge) returns Pledge|error {
        return self.pledgeClient->create(pledge);
    }

    resource function get .() returns Pledge[]|error? {
        return from Pledge pledge in self.pledgeClient->read(["package", "donor"])
               select pledge;
    }

    resource function get [int pledgeId]() returns Pledge|error {
        return self.pledgeClient->readByKey(pledgeId, ["package", "donor"]);
    }

    resource function put .(@http:Payload Pledge pledge) returns Pledge|error {
        check self.pledgeClient->update(pledge);
        return pledge;
    }

    resource function delete [int pledgeId]() returns error? {
        Pledge pledge = check self.pledgeClient->readByKey(pledgeId);
        check self.pledgeClient->delete(pledge);
    }
}
