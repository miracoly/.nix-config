# My Nix Configuration

## Sops-Nix using age

1.Create a new age key on the host system.

```shell
age-keygen -y /var/lib/sops-nix/key.txt
```

2. Add the fingerprint to `.sops.yaml`:

```yaml
keys:
  - &machine-name age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
creation_rules:
  - path_regex: '.*'
    key_groups:
      - age: *machine-name
```

3. Re-encrypt the secrets:

```shell
sops updatekeys <file>
```
