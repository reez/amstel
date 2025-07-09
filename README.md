# Amstel Wallet

Amstel is a macOS desktop app to manage descriptor-based Bitcoin wallets. It is built with SwiftUI, [Bitcoin Dev Kit](https://github.com/bitcoindevkit), and the BDK [Foreign Language Bindings](https://github.com/bitcoindevkit/bdk-ffi). Wallet data is sourced from the block chain using compact block filters with the [Kyoto](https://github.com/2140-dev/kyoto) BIP-157 and BIP-158 implementation.

## Philosophy

Managing Bitcoin should be simple and boring. The user interface of Amstel is intentionally limited in visual cluter. There are three main actions one would do when using wallet that manages hardware signer(s): create a transaction, send a transaction, receive a payment. Each of these are found in the top right corner of the screen as simple icons. Building a transaction involves a very simple flow that requires you to confirm your step at every configuration. Sending a transction also requires you to confirm the destination address. Receiving a transction can be done by scanning a QR code or copying an address.

## Build

Application binaries are not distributed yet. Currently, the repository is built on a fork of BDK FFI, and will be migrated to an official version of BDK Swift after BDK FFI 2.0.0 is released.

## Maintenance

This repository will be maintained to the degree it remains relevant. If [Bitcoin Core](https://github.com/bitcoin/bitcoin) implements compact block filter syncing for light clients, then this wallet becomes superfluous. As long as wallet is useful, then it will be maintained. Import file formats will remain backward compatible.

## Disclaimer

This app may contain bugs, use it at your own risk.

## FAQ

```Q: Will Amstel release on other plaforms?```

No, to keep the project maintainable, macOS is the only supported target. I recommend the [Bitcoin Safe](https://github.com/andreasgriffin/bitcoin-safe) project.

```Q: What desciptors does Amstel support?```

Amstel supports Segwit and Taproot output types.

```Q: Why is the initial sync so long?```

Compact block filter nodes must check every filter for inclusion of relevant scripts. When considering an import of a new descriptor, it is uncertain if this is a new or used descriptor, so each block must be checked. Every sync thereafter will be orders of magnitude shorter.

```Q: Why can't I view a receiving address while the node is initially syncing?```

To prevent address re-use, the node must be up-to-date with the block chain. Be patient and grab a coffee.

```Q: Can Amstel help me build a multisignature descriptor?```

At the moment, no. This will depend on demand for such a feature.

```Q: Will Amstel support <XYZ> hardware signer in the future?```

Maybe, but this would require a port of HWI to C or Swift. This will also depend on feature demand. Any signer that supports multiple cryptocurrencies will not be supported.

## Contributions

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.

## License

Licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or <https://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or <https://opensource.org/licenses/MIT>)

at your option.
