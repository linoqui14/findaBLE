requests = [
            {
                "type": "GET",
                "status": 200,
                "page": "example.com/one"
            },
            {
                "type": "POST",
                "status": 200,
                "page": "example.com/two"
            },
            {
                "type": "GET",
                "status": 404,
                "page": "example.com/three"
            },
            {
                "type": "POST",
                "status": 403,
                "page": "example.com/four"
            },
            {
                "type": "GET",
                "status": 500,
                "page": "example.com/five"
            },
            {
                "type": "GET",
                "status": 403,
                "page": "example.com/six"
            },
            {
                "type": "POST",
                "status": 403,
                "page": "example.com/seven"
            },
            {
                "type": "GET",
                "status": 403,
                "page": "example.com/eight"
            }
        ]
forbidden_requests = [request for request in requests if request['status']==403] #this is not that readable but it will do the work
#or you can do
for request in requests:
    if request['status']==403:
        forbidden_requests.append(request)
# both can do the work but this is more readable.

