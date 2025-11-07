# racpad-secure-config

Module that reads secrets from an encrypted YAML file `secure-config.enc`.

- The encrypted blob (the binary `secure-config.enc` file) is not committed; place it in `rac_pad_secure/src/main/resources/` locally.
- Decryption key must be provided via `-DMASTER_KEY=...` or env `MASTER_KEY`.
- At runtime the loader first looks on the classpath for `secure-config.enc` and
  then searches common project paths. If the file can't be found or decrypted,
  initialization fails.

The YAML structure is two levels:
```
<ENVIRONMENT>:
  apiTokens: { ... }
  dbTokens: { ... }
  awsTokens: { ... }
```

## Seal your config
1) Create a plaintext YAML file, e.g. `config.plain.yaml`, using the structure above.
2) Compile the module so the sealing CLI is available:
   ```bash
   mvn -q -pl rac_pad_secure -am compile
   ```
3) Seal to an encrypted blob:
   ```bash
   "%JAVA_HOME%\bin\java.exe" -DMASTER_KEY="SEC_KEY" -cp rac_pad_secure/target/classes com.rentacenter.racpad.securecfg.ConfigSealCli seal ./config.plain.yaml ./secure-config.enc
   ```
4) Place the resulting `secure-config.enc` into `rac_pad_secure/src/main/resources/` (ignored by git).
5) Build or install as needed so other modules can depend on it:
   ```bash
   mvn -q -pl rac_pad_secure -am install
   ```

## Runtime
- At startup the library attempts to load `secure-config.enc` and decrypt it using `MASTER_KEY`.
- There is no plaintext fallback; missing or mismatched blobs halt startup.

## Security notes
- Do NOT commit `config.plain.yaml`, `secure-config.enc`, or `MASTER_KEY`.
- CI/CD should copy the encrypted blob into `src/main/resources` during the build.
