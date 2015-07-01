# api notes

>>>

## HTTP Response codes

When to use what.

```
GET success          = 200 - OK
POST success         = 201 - Created
delayed POST success = 202 - Accepted
DELETE success       = 204 - No Content
PATCH/PUT success    = 205 - Reset Content
Missing parameters   = 400 - Bad Request
Invalid scope        = 403 - Forbidden
No privilege         = 403 - Forbidden
Record not Found     = 404 - Not Found
Sanity Check fail    = 412 - Precondition Failed
```

### 204 - No Content

Under NO CIRCUMSTANCE is a response body allowed, see [RFC 2616#9.7](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.7)

### 410 - Gone

We *could* check the MAX auto increment value with

```sql
SELECT nextval('answers_id_seq') AS next_id FROM answers LIMIT 1
```

and return `410 - Gone` if the requested ID is below that value and not found.

### 412 - Precondition Failed

Example: Subscriptions (`sleipnir/answer_api.rb`)

### PUT requests

It MUST redirect and respond with the resulting entity(s)

## FLAGS variable

Sleipnir uses a bitwise operator syntax for flags, replacing older indices
(i.e. replacing `twitter` in `FLAGS = ['twitter', 'tumblr']`) will result in
older apps not updated to the new flag order to send invalid and unexpected
requests.

### Detours/Possible Fixes

Provide a `#{flags_variable_name}.:format` API for any endpoint that provides
flags, but this only works for apps that use the API, many will still hardcode.
