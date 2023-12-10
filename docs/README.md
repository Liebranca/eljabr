# ELJABR

Custom classes for working with algebraic expressions.

# DEPS

- [avtomat](https://github.com/Liebranca/avtomat)

# SETUP

```bash
cd  $ARPATH
git clone https://github.com/Liebranca/eljabr
eljabr/install.pl
eljabr/avto
```

That will build the project into `$ARPATH/lib/eljabr/`.

# CHANGELOG

### v0.00.4b

- Added `*::con::FRAC_RE` to detect terms with fractions.

- Added initial *barebones* support for clearing fractions with `*::over(1/x)`.

- `histc` no longer gets confused with fractional constants.

### v0.00.3b

- `*::expr` methods no longer run automatic `update`.

- Running of `update` moved to `*::expr` wraps, ran by container.

- Wrapped `update` adds a comment detailing the edit and pushes to a history array.

- `hist` method added for printing out container `update` history.

- `histc` for doing the same, but with colors ;>

### v0.00.2b

- Added `over` method for term/expr division.

- Simplified term-value extraction with `*::expr` guts `_tex` and `_texv` methods.

- `*::con::VAR` re now accounts for the variable multiplier.

### v0.00.1b

- Turned a literal scratch buffer into a repo.
