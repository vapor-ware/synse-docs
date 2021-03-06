
!!! note
    *Added in: 3.0.0*

Synse uses *tags* to group and identify devices in the system. Tags can be arbitrary and
are assigned to devices at the plugin level. Synse also auto-generates system level tags
for devices to provide some simple baked-in groupings.

At a minimum, all devices will have an `id` tag. Every `id` tag will only ever reference
a single device for a given plugin.

## Definitions

Below are some basic definitions around the nomenclature used to describe device tags.

| Term | Definition |
| ---- | ---------- |
| *tag* | A single string that acts as a group identifier to which an associated Synse device belongs. |
| *label* | A component of the *tag*. The label corresponds to the group name. |
| *annotation* | An optional prefix to the *label* component of the tag. It provides context for the label. |
| *namespace* | An optional prefix to the *annotation*/*label* component(s) of the tag. It serves to provide tag scoping. |
| *tag components* | The collection of the *label*, *annotation*, and *namespace* components. |

## Tag Anatomy

```

 [NAMESPACE/][ANNOTATION:]LABEL

```

The scheme above shows all components which make up a tag. Components in square brackets are optional. 
Below, each component is described in more detail.

### Label

The label is the only required component of the tag. A tag may consist of only a label. The label
is just a name which is used to identify a group which devices may be a member of. A label group
can have 1..N members.

> **Exception**: The *only* label group which will not have 1..N members is the reserved `id`
tag. This tag will have exactly 1 member.

If a tag consists of only a label, it will automatically be put into the `default` namespace,
so `foo` and `default/foo` are effectively equivalent.

### Annotation

The annotation is an optional prefix to the *label* component. It is separated from the
label with a colon (`:`). Annotations can be used to provide additional context and scoping
to a label. [Auto-generated tags](#auto-generated) will always use annotations; the
annotation values for auto-generated tags are reserved and will result in an SDK error
if a user tries to use them.

A tag may have only one annotation.

#### Reserved Annotations

Auto-generated tags reserve the following annotations:

- `id:`
- `type:`

### Namespace

The namespace is an optional prefix to a *label* or *annotation* component. It is separated
from the annotation or label with a forward slash (`/`). Namespaces allow the formation of 
different tag profiles, where there might otherwise be overlap with tag names. It is important
to note that the namespace applies only to the tag it is a component of; it does not apply
to the device itself (e.g. a single device can have multiple tags in different namespaces).

A tag without an explicit namespace defined will be put into the `default` namespace.
The default namespace may also be applied explicitly, e.g. `default/foo`. The "default" namespace
name is reserved.

A tag may have only one namespace.

#### System-wide Namespace

Some tags may need to apply to all namespaces, such as the auto-generated `id` tag. For
such cases, the *system-wide namespace* should be used. This namespace, identified with 
`system/`, considers the tag a member of all namespaces. While possible, it is discouraged
to put custom tags into the system-wide namespace.

### Tag

A tag is the combination of all components described above. It is a single string with
the (optional) *namespace*, (optional) *annotation*, and (required) *label* components.

They are used to reference devices in Synse. Some API endpoints only require the device ID.
In this case, only the ID string needs to be provided (Synse will automatically format it
into the appropriate ID tag). Other endpoints can take a collection of tags to filter
devices by. See the [API Documentation](../api.v3.md) for more details.

It is important to note that within a *tag group*, tag filtering is subtractive, not additive.
This means that Synse will only select the devices which match each specified tag. For additive
behaviors, multiple tag groups may be specified.

## Tag Types

### Auto Generated

Auto-generated tags are tags which are associated with a device automatically, without
any need for user configuration. These tags are currently limited to `id` and `type`.

All auto-generated tags will include an annotation component. The annotation will be [well-known
and reserved](#annotation) from use in [user-defined tags](#user-defined). If a user-defined
tag annotation conflicts with a reserved annotation name, an error is returned.

### User Defined

User-defined tags may be specified for a device in the device's [configuration](../../sdk/configuration/device.md).
For example:

```yaml
tags:
- synse/fan-sensor
```

If any component of a user-defined tag conflicts with a reserved name, an error is returned.

## Formatting

Below are the rules for tag formatting:

- Tags must be strings
- Tags are case-insensitive (prefer all lower cased)
- Tag components may NOT contain any of the delimiter characters (`:`, `/`, `,`)
- Tags may not contain spaces

## Examples

0. **A tag consisting of only a label**
   ```
   temperature
   ```
0. **A tag consisting of an annotation and a label**
   ```
   type:temperature
   ```
0. **A tag consisting of a namespace and a label**
   ```
   vaporio/temperature
   ```
0. **A tag consisting of a namespace, annotation, and a label**
   ```
   vaporio/type:temperature
   ```
0. **Explicitly setting a tag to the default namespace**
   ```
   default/temperature
   ```
0. **Passing a single tag to Synse Server**
   ```
   ?tags=vaporio/type:temperature
   ```
   The above query parameter(s) translates to the following tag(s):
   ```
   vaporio/type:temperature
   ```
0. **Passing multiple tags (single group) to Synse Server**
   ```
   ?tags=vaporio/type:temperature,foo,other/bar
   ```
   The above query parameter(s) translates to the following tag(s):
   ```
   vaporio/type:temperature
   default/foo
   other/bar
   ```
0. **Passing multiple tags (multiple groups) to Synse Server**
   ```
   ?tags=vaporio/type:temperature,foo&tags=other/bar
   ```
   The above query parameter(s) translates to the following tag groups:
   ```
   vaporio/type:temperature
   default/foo
   ```
   ```
   other/bar
   ```
0. **Setting a namespace and specifying a tag to Synse Server**
   ```
   ?ns=vaporio&tags=type:temperature
   ```
   The above query parameter(s) translates to the following tag(s):
   ```
   vaporio/type:temperature
   ```
0. **Setting a namespace and specifying some namespaced tags to Synse Server**
   ```
   ?ns=vaporio&tags=vaporio/type:temperature,foo,other/bar
   ```
   The above query parameter(s) translates to the following tag(s):
   ```
   vaporio/type:temperature
   vaporio/foo
   other/bar
   ```  
