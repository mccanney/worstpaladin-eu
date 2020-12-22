<h1 align="center">Welcome to s3-bucket-module 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-2.0.1-blue.svg?cacheSeconds=2592000" />
  <a href="https://github.com/mccanney/worstpaladin-eu/blob/master/LICENSE.md" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" />
  </a>
</p>

> A terraform module to create a standard S3 bucket in AWS.

### 🏠 [Homepage](https://github.com/mccanney/worstpaladin-eu/modules/s3-bucket)

## Install

To use the module, set the source to pull the code directly from GitHub.

```hcl
terraform {
  source = "github.com/mccanney/worstpaladin-eu//modules/s3-bucket?ref=v2.0.1"
}
```

`bucket_name` and `environment` are the input variables.

## Run tests

The tests are written in Go using the [terratest](https://terratest.gruntwork.io/) library.

```sh
cd test
go test -v -run TestUT_S3Bucket -timeout 30m
```

## Author

👤 **David McCanney**

- Website: https://www.mccanney.io
- Github: [@mccanney](https://github.com/mccanney)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/mccanney/worstpaladin-eu/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2020 [David McCanney](https://github.com/mccanney).<br />
This project is [MIT](https://github.com/mccanney/worstpaladin-eu/blob/master/LICENSE.md) licensed.

---

_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
