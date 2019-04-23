# Beauty
```@meta
CurrentModule = Beauty
```

This package provides Beauty for the output of
[julia](https://julialang.org) programs. See for yourself.

### Conventional Output

To produce conventional output, simply generate a sample measurement
of an electrical current using the well-suited packages
[Unitful](https://github.com/ajkeller34/Unitful.jl) and
[Measurements](https://github.com/JuliaPhysics/Measurements.jl):

```@example first
using Unitful, Measurements
using Unitful: mA
I = sqrt(2)/2 * (100 ± 0.5) * mA
show(IOContext(stdout), I) # hide
```

It is tempting to try `round(I, sigdigits=3)` but that is not defined
for `Unitful.Quantity` because the author considers rounding to be
ill-defined for numbers that are not dimensionless.  Another example
is viewing a [DataFrame](https://github.com/JuliaData/DataFrames.jl):

```@example first
using DataFrames
df = DataFrame(Property = ["Current"], Value = [I])
show(IOContext(stdout), df) # hide
```

### Output with Beauty

Continuing the above example, see what happens when using `Beauty`:

```@example first
using Beauty
I
show(IOContext(stdout), "text/plain", I) # hide
```

Instead of a long list of meaningless digits, you only see significant
digits with scientific notation for the uncertainty. The DataFrame
renders nicely as well:

```@example first
df
```

Finally, Beauty also defines a way to round `Unitful.AbstractQuantity`
(requiring the `sigdigits` keyword argument) such that you can remove
excessive uncertainty:

```@example first
# note: this implementation does not work properly yet, because # hide
#       1) the optional argument for the rounding mode for the imaginary component needs to be implemented # hide
#       2) the output it produces does not seem to be rounded # hide
# hide
Base.round(x::Unitful.AbstractQuantity{T,D,U}; sigdigits, kwargs...) where {T,D,U} = # hide
    round(x / Unitful.unit(x); sigdigits=sigdigits, kwargs...) * Unitful.unit(x) # hide
Base.round(x::Unitful.AbstractQuantity{T,D,U}, modeReal; sigdigits, kwargs...) where {T,D,U} = # hide
    round(x / Unitful.unit(x), modeReal; sigdigits=sigdigits, kwargs...) * Unitful.unit(x) # hide
function Base.round(x::Measurements.Measurement{Float64}; sigdigits, kwargs...) # hide
    val = Measurements.value(x) # hide
    y = round(val; sigdigits=sigdigits, kwargs...) # hide
    z = Measurements.uncertainty(x) # hide
    if z > round(val * 0.1^sigdigits, RoundUp; sigdigits=0, kwargs...) # hide
        return Measurements.measurement(y, z) # hide
    end # hide
    return y # hide
end # hide
function Base.round(x::Measurements.Measurement{Float64}, modeReal; sigdigits, kwargs...) # hide
    val = Measurements.value(x) # hide
    y = round(val, modeReal; sigdigits=sigdigits, kwargs...) # hide
    z = Measurements.uncertainty(x) # hide
    if z > round(val * 0.1^sigdigits, RoundUp; sigdigits=0, kwargs...) # hide
        return Measurements.measurement(y, z) # hide
    end # hide
    return y # hide
end # hide
nothing # hide
```

```@example first
round(I, sigdigits=1)
show(IOContext(stdout), "text/plain", I); nothing # hide
```

!!! info "To Do"
    Incorporate this rounding function into the code base
    (see `index.md` for an implementation hidden from index.html).
    It already seems to work when entered into the REPL (but not
    yet in the above example), so it is expected that the example
    will work once the `Base.round` method is defined in the actual
    code base.

!!! info "To Do"
    Reconsider the design of this method that currently is not
    type-stable: It returns a `Measurements.Measurement` if
    one tries to round "too much" but the underlying type if
    one actually adds uncertainty by the restriction to only
    `sigdigits` significant digits. Perhaps this needs to be
    split into two different methods.

# Usage

If you have ever used a julia package (outside of the standard
library), you know the drill: Add the package with the package manager
or `using Pkg`, then use it with `using Beauty`.

That's it. Enjoy Beauty.

If you are still not satisfied, read on to learn how to configure
aspects of the output to suit your taste (in Section
[Configuration](@ref)) or discover Beauty's [Internals](@ref). Or you
could read on in this Section to learn about normal usage.

!!! note "In the Eye of the Beholder"
    Beauty is very opinionated about what constitutes Beauty and
    when to apply it (rather than not robbing you of valuable debug
    information by omitting data in the name of Beauty). If you
    don't like it, don't use it—or help make it suit your taste by
    contributing code for more configurability.

# `IOContext` Properties

Julia provides a type and constructor method `IOContext` to modify the
properties of an existing `IOContext`. It can be used to influence
output formatting. To illustrate, consider the following code
examples.

!!! note "Beauty vs No Beauty"
    Here and in the entire documentation of Beauty, it is not assumed
    in the code examples that you actually issue the statement
    `using Beauty` unless explicitly mentioned. Code examples without
    either that statement, or with preceding text to indicate they are
    a continuation of code that already had that statement, is meant
    to illustrate general output even without having issued the
    statement `using beauty`.

This outputs a `Measurements.Measurement` in the usual format:
```@example IOContext-example-1
    using Measurements
    value = sqrt(2)/2 * (100 ± 0.5) # prepare a measurement value
    show(stdout, value) # get normal output; stdout may be omitted
```

This, continuing the above example, outputs in a somewhat terser format:
```@example IOContext-example-1
    io = IOContext(stdout, :compact => true) # ask for short output
    # hide
    # we must simulate this, as Documenter.jl seems to not like it # hide
    buf = IOBuffer() # hide
    io = IOContext(buf, :compact => true) # hide
    # hide
    show(io, value) # get somewhat terser output
    # hide
    print(String(take!(buf))) # hide
```

The common options to an IOContext are naturally understood by Beauty,
where applicable:

!!! info "To Do"
    Check that the above statement is correct and if not, make it so.

| Option     | Default | Meaning                             | Handling by Beauty                |
|:-----------|:-------:|:----------------------------------- |:--------------------------------- |
| :compact   | false   | terser output                       | Currently ignored.                |
| :limit     | false   | limit the number of elements output | This option is ignored by design. |
| :displaysize | ?     | influences `displaysize` method     | This option is ignored by design. |
| :typeinfo  | absent  | type information already output     | This option is ignored by design. |
| :color     | false   | color output is supported/expected  | Influences type output.           |

There are more (nonstandard) `IOContext` properties in use by Beauty:

| Option     | Default | Handling by Beauty                |
|:-----------|:-------:|:--------------------------------- |
| :unicode   | :color  | Turn on unicode output.           |


# Configuration

!!! info "To Do"
    Provide ways to configure it (e.g. changing defaults like the
    maximum number of significant digits being displayed for numbers
    without given uncertainty). Also consider an option to "turn it
    off", perhaps as a property of an `IOContext`.    

## Output Units

Beauty tries to find neatly fitting output units, within reason. You
can amend its logic by providing one or more
[`force_display_units`](@ref) methods.

For example, to disable this
logic and always output the given units, declare

```@example
using Beauty, Unitful
Beauty.force_display_units(
    ::Any,
    value::Unitful.AbstractQuantity
) = Unitful.unit(value)
nothing # hide
```

Conversely, to always convert powers to kW, amend by the following
method:

```@example
using Beauty, Unitful
Beauty.force_display_units(
    ::Any,
    value::Unitful.Power
) = Unitful.kW
nothing # hide
```

# Internals

`Beauty` is a package for the programming language julia that replaces
and augments `Base.show` methods to produce beautiful output. It uses
the package [Requires](https://github.com/MikeInnes/Requires.jl) to
provide methods based on optional dependencies: These must be loaded
manually but then the augmentation methods provided for it appear
automatically.

## Show Method
```@docs
Base.show
```

## Helpers
```@docs
Beauty.hasunicodesupport
Beauty.unicode_superscript_digits
Beauty.stringreplace
```

## Behavior Determining Methods
```@docs
force_display_units
```
