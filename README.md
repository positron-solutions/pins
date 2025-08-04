# Pins

This repo demonstrates a solution to control upgrades centrally, meaning all
your leaf repos get the same version and you only need to pin in one place and
update one input in leaf repos.

Read about it [on our blog](https://positron.solutions/articles/centralizing-nix-dependencies).

The contained Nix flake provides the inputs like those that our projects use.
Because of how Nix lockfiles work, updates to dependent projects are lazy and
you can update them individually whenever it is convenient.  Projects can also
override the flake in-detail.  It provides the advantages of central declaration
while retaining the flexibility of polyrepo.

In downstream projects, we declare pins as the only concrete input and every
other input comes from pins.  This centralizes all concrete input definitions in
pins and makes its lock file control all of our leaf repos.

```nix
  inputs = {
    pins.url = "git+https://github.com/positron-solutions/pins.git";

    systems.follows = "pins/systems";
    nixpkgs.follows = "pins/nixpkgs";
    fenix.follows = "pins/fenix";
    crane.follows = "pins/crane";
    flake-parts.follows = "pins/flake-parts";
  };
```

To reveal that all inputs share dependency versions, show the dependency tree:
```
nix flake metadata
```

Inputs that don't use `follows` should be made explicit inputs of the pins flake
and then the dependent input should follow the top-level explicit input.

## Maintenance

Nix is a rolling release with periodic stable branches.  Every six months or so,
Nixpkgs cuts a new branch.  Edit the branch, such as `25.05`, in the flake.nix
and then update the lockfile: 

```
nix flake update nixpkgs
```

Update other inputs using `nix flake update`.

Finally, upate the pins flake in all of your leaf repos.

```
nix flake update pins
```

## Synchronization of CLI Commands With the Registry

Having nixpkgs pinned to the same rev that your repos are using further speed up
a lot of nix CLI operations.  In the Nix registry, you can make your nixpkgs
depend on the version found in this repo.  Instead of downloading new versions
of nixpkgs for basic commands like `nix search`, the same version of packages
will be used.  If you add a package to a project, it will be the same version as
one obtained from running `nix shell`.

To pin nixpkgs, just add a pin pointing to the same rev visible in `nix flake
metadata`.  (We would like to delegate this to the pins reference in the
registry but this might not be possible with the current version of the Nix
package manager).

```nix
nix registry pin nixpkgs github:NixOS/nixpkgs/f0946fa5f1fb876a9dc2e1850d9d3a4e3f914092
```

After a nix command obtains nixpkgs once, it won't download it again until you
update the registry pin.
