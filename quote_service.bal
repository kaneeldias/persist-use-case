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
