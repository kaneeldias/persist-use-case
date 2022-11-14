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

service /quotes on new http:Listener(8080) {

    final clients:QuoteClient quoteClient = check new ();

    function init () returns error? {}

    resource function post .(@http:Payload Quote quote) returns Quote|error {
        return self.quoteClient->create(quote);
    }

    resource function get .() returns Quote[]|error? {
        return from Quote quote in self.quoteClient->read(["supplier", "item"])
               select quote;
    }

    resource function get [int quoteId]() returns Quote|error {
        return self.quoteClient->readByKey(quoteId, ["supplier", "item"]);
    }

    resource function put .(@http:Payload Quote quote) returns Quote|error {
        check self.quoteClient->update(quote);
        return quote;
    }

    resource function delete [int quoteId]() returns error? {
        Quote quote = check self.quoteClient->readByKey(quoteId);
        check self.quoteClient->delete(quote);
    }
}
