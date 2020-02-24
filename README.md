# CurlGen

This Swift Package is a μframework for debugging with Swift Foundation's URLRequests, converting them to cURL commands that can easily be copy and pasted to execute or inspect details.

Example:

```sh
(lldb) po request.cURLCommand()

curl -v https://www.github.com -X POST \
--data {"data": {"key": "value"}} \
--header "Accept=application/json" \
--header "Content-Type=application/json"
```

## Prerequisites

- Xcode 11.0 or higher

## Installing

Just add the Swift Package to your Xcode project in Project settings, "Swift Packages."

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Inspired by Alamofire's cURL command generator, I wanted something similar, but useable in cases where I didn't use Alamofire.

## TODO
- [ ] Put all urls, headers, and body in single quotes for shell escaping
