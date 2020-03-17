---
hero: Output Types
---

The Synse plugin SDK provides a number of built-in reading output types with sane values
which can be used by any plugin. This "core" set of outputs provides a good foundation
to describe what data plugins can support, but individual plugin implementations are free
to define their own outputs.

## Built-ins

Below is a table describing the outputs built-in to the SDK. If you are interested in
adding more built-in outputs, feel free to open a pull request. In the table below,
a value of `-` indicates no value.

| Name | Type | Precision | Unit |
| :--- | :--- | :-------: | :--- |
| color | `color` | - | - |
| direction | `direction` | - | - |
| electric-current | `current` | 3 | Ampere (A) |
| electric-resistance | `resistance` | 2 | Ohm (Ω) |
| frequency | `frequency` | 2 | Hertz (Hz) |
| humidity | `humidity` | 2 | Percent humidity (%) |
| kilojoule | `energy` | 3 | Kilojoule (kJ) |
| kilowatt-hour | `energy` | 3 | Kilowatt-hour (kWh) |
| microseconds | `duration` | 6 | Microseconds (µs) |
| nanoseconds | `duration` | 6 | Nanoseconds (ns) |
| pascal | `pressure` | 3 | Pascal (Pa) |
| percentage | `percentage` | - | Percent (%) |
| psi | `pressure` | 3 | Pounds per square inch (PSI) |
| rpm | `frequency` | 2 | Revolutions per minute (RPM) |
| seconds | `duration` | 3 | Seconds (s) |
| state | `state` | - |  - |
| status | `status` | - | - |
| switch | `state` | 1 | -  |
| temperature | `temperature` | 2 | Celsius (C) |
| velocity | `velocity` | 3 | Meters per second (m/s) |
| voltage | `voltage` | 5 | Volt (V) |
| volt-second | `flux` | 3 | Volt second (Vs) |
| watt | `power` | 3 | Watt (W) |
| weber | `flux` | 3 | Weber (Wb) |

## Documenting Outputs

Whether a plugin uses built-in outputs, custom outputs, or a mix of both, it is helpful
to plugin users to document which outputs that plugin uses. Such documentation could look
something like this:

-----

### Outputs

Outputs are referenced by name. A single device may have more than one instance
of an output type. A value of `-` in the table below indicates that there is no value
set for that field. The *custom* section describes outputs which this plugin defines
while the *built-in* section describes outputs this plugin uses which are built-in to
the SDK.

**Custom**

| Name    | Description                                      | Unit  | Type    | Precision |
| ------- | ------------------------------------------------ | :---: | ------- | :-------: |
| airflow | A measure of airflow, in millimeters per second. | mm/s  | `speed` | 3         |

**Built-in**

| Name          | Description                                        | Unit  | Type          | Precision |
| ------------- | -------------------------------------------------- | :---: | ------------- | :-------: |
| color         | A color, represented as an RGB string.             | -     | `color`       | -         |
| direction     | A measure of directionality.                       | -     | `direction`   | -         |
| humidity      | A measure of humidity, as a percentage.            | %     | `humidity`    | 2         |
| kilowatt-hour | A measure of energy, in kilowatt-hours.            | kWh   | `energy`      | 3         |
| pascal        | A measure of pressure, in Pascals.                 | Pa    | `pressure`    | 3         |
| rpm           | A measure of frequency, in revolutions per minute. | RPM   | `frequency`   | 2         |
| state         | A generic description of state.                    | -     | `state`       | -         |
| status        | A generic description of status.                   | -     | `status`      | -         |
| temperature   | A measure of temperature, in degrees Celsius.      | C     | `temperature` | 2         |
| voltage       | A measure of voltage, in Volts.                    | V     | `voltage`     | 5         |
| watt          | A measure of power, in Watts.                      | W     | `power`       | 3         |

-----

As markdown, the above is:

```md
### Outputs

Outputs are referenced by name. A single device may have more than one instance
of an output type. A value of `-` in the table below indicates that there is no value
set for that field. The *custom* section describes outputs which this plugin defines
while the *built-in* section describes outputs this plugin uses which are built-in to
the SDK.

**Custom**

| Name    | Description                                      | Unit  | Type    | Precision |
| ------- | ------------------------------------------------ | :---: | ------- | :-------: |
| airflow | A measure of airflow, in millimeters per second. | mm/s  | `speed` | 3         |

**Built-in**

| Name          | Description                                        | Unit  | Type          | Precision |
| ------------- | -------------------------------------------------- | :---: | ------------- | :-------: |
| color         | A color, represented as an RGB string.             | -     | `color`       | -         |
| direction     | A measure of directionality.                       | -     | `direction`   | -         |
| humidity      | A measure of humidity, as a percentage.            | %     | `humidity`    | 2         |
| kilowatt-hour | A measure of energy, in kilowatt-hours.            | kWh   | `energy`      | 3         |
| pascal        | A measure of pressure, in Pascals.                 | Pa    | `pressure`    | 3         |
| rpm           | A measure of frequency, in revolutions per minute. | RPM   | `frequency`   | 2         |
| state         | A generic description of state.                    | -     | `state`       | -         |
| status        | A generic description of status.                   | -     | `status`      | -         |
| temperature   | A measure of temperature, in degrees Celsius.      | C     | `temperature` | 2         |
| voltage       | A measure of voltage, in Volts.                    | V     | `voltage`     | 5         |
| watt          | A measure of power, in Watts.                      | W     | `power`       | 3         |
```
