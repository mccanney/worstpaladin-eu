# worstpaladin.eu

> From morn\
> To noon he fell, from noon to dewy eve,\
> A summer's day; and with the setting sun\
> Dropped from the zenith like a falling star.

-- John Milton, _Paradise Lost; Book I, lines 742-745_

[![CircleCI](https://circleci.com/gh/mccanney/worstpaladin-eu.svg?style=shield)](https://circleci.com/gh/mccanney/worstpaladin-eu)
[![GitHub release](https://img.shields.io/github/release/mccanney/worstpaladin-eu.svg?style=flat-square)](https://github.com/mccanney/worstpaladin-eu/releases)
[![license](https://img.shields.io/github/license/mccanney/worstpaladin-eu.svg?style=flat-square)](https://github.com/mccanney/worstpaladin-eu/blob/master/LICENSE.md)
[![Website](https://img.shields.io/website-up-down-green-red/http/worstpaladin.eu.svg?label=worstpaladin.eu&style=flat-square)](http://worstpaladin.eu)

A web application which uses the power of distributed processing and machine learning to carefully determine which World of Warcraft Paladin is the worst in the EU.

## How does it work?

Accessing the site http://worstpaladin.eu will instanteously analysis every level 1 to 60 Paladin-class character on Blizzard's EU World of Warcraft servers. Over 10,000 data points will be examined and the details of the worst character returned.

## Dependencies

- [Terraform](https://github.com/hashicorp/terraform)
- [AWS CLI](https://github.com/aws/aws-cli)

## Contributing

Please use the [issue tracker](https://github.com/mccanney/worstpaladin-eu/issues) to file any bug reports or make feature requests.

## License

Released under the [MIT license](LICENSE.md).
