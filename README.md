# Pins

This repo demonstrates a solution for centralizing all of your dependency
declarations for your projects.

The contained Nix flake provides the inputs that our projects use.  Because of
how Nix lockfiles work, udpates to dependent projects are lazy and you can
update them individually whenever it is convenient.  Projects can also override
the flake in-detail.  It provides the advantages of central declaration while
retaining the flexibility of polyrepo.

It is made available by adding this flake to your registry:

```
nix registry add pins git+https://github.com/positron-solutions/pins.git
```

In downstream projects, we declare our inputs relative to pins, like so:

```nix
  inputs = {
    pins.url = "pins";

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

## Maintenance

Every six months or so, Nixpkgs cuts a new branch.  Update the `24.11` names in
the flake.nix and then update the lockfile:

```
nix flake lock --update-input nixpkgs
```

Update other inputs using similar commands as desired.  Do not update them too
frequently without updating pins in downstream projects:

```
nix flake lock --update-input pins
```

## Pinned Flakes

The Fenix flake should be of particular interest.  It effectively pins a Rust
version.  Updating Fenix will therefore update the version of Rust that is
avaialable in downstream.  Again, just update the input for Fenix in each
project.  If a project doesn't work, roll back its lock file and fix it when you
get more time.

Having nixpkgs pinned can also speed up a lot of operations.  In the Nix
registry, you can make your nixpkgs depend on the version found in this repo.
Instead of downloading new versions of nixpkgs for basic commands like `nix
search`, the same version of packages will be used.  If you add a package to a
project, it will be the same version as one obtained from running `nix shell`.
To pin nixpkgs, just add a pin pointing to the same rev visible in `nix flake
metadata`.  (We would like to delegate this to the pins reference in the
registry but this might not be posssible with the current version of the Nix
binary).

```nix
nix registry pin nixpkgs github:NixOS/nixpkgs/f0946fa5f1fb876a9dc2e1850d9d3a4e3f914092
```

After a nix command obtains nixpkgs once, it won't download it again until you
update the registry pin.
