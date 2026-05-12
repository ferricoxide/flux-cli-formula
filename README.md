flux-cli-formula
==================

A SaltStack formula designed to install and configure the [Flux](https://fluxcd.io/flux/cmd/) CLI utility on installation-targets.

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install the Flux CLI on both Linux[^1] and Windows Server[^2] operating environments. Intallation for internet-connected systems will come from the Flux CLI project's ["releases" page](https://github.com/fluxcd/flux2/releases).


## Available states

- [flux-cli](#flux-cli)
- [flux-cli.clean](#flux-cli.clean)
- [flux-cli.package](#flux-cli.package)
- [flux-cli.package.clean](#flux-cli.package.clean)
- [flux-cli.config](#flux-cli.config)
- [flux-cli.config.clean](#flux-cli.config.clean)

### flux-cli

Executes the `package` and `config` states to install and configure the Flux CLI

### flux-cli.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the Flux CLI and remove previously-installed browser policy-configs (and, on Windows, associated registry entries)

### flux-cli.package

Executes _just_ the `package` state to install the Flux CLI package.

### flux-cli.package.clean

Executes _just_ the `package.clean` state to uninstall the Flux CLI package.

### flux-cli.config

Executes _just_ the `config` state to install/configure the Flux CLI client-configuration (etc.) files

### flux-cli.config.clean

Executes _just_ the `config` state to uninstall the Flux CLI client-configuration (etc.) files and, on Windows, remove any registry-keys set by prior install-runs of the formula.



[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux). It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
