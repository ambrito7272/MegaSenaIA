"""Provider de demonstração — simula um carro real sem hardware.

Ciclo: acelera por marchas até 220 km/h, cruzeiro, desaceleração e
parada em ponto morto, repetindo. Eventos ocasionais (superaquecimento,
bateria fraca) exercitam o sistema de alertas.
"""

import datetime as _dt
import random
import threading
import time

from app.data.data_provider import DataProvider
from app.domain.alerts import Alert, AlertSeverity
from app.domain.vehicle_data import VehicleData

UPDATE_HZ = 20

SPEED_STEPS = (0, 40, 80, 120, 140, 160, 180, 200, 220)
GEAR_TOP_RPM = (3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500)
ENGAGE_RPM = 1200.0
IDLE_RPM = 900.0

ACCEL_RATE = 22.0
BRAKE_RATE = 30.0
STEP_HOLD_SECONDS = 9.0


class DemoDataProvider(DataProvider):
    def __init__(self) -> None:
        super().__init__()
        self._thread: threading.Thread | None = None
        self._rng = random.Random()
        self._reset_simulation()

    def _reset_simulation(self) -> None:
        self._speed = 0.0
        self._rpm = IDLE_RPM
        self._temperature = 25.0
        self._oil_pressure = 0.0
        self._battery_voltage = 12.6
        self._vacuum = 0.0
        self._amperage = 0.0
        self._fuel_level = 95.0
        self._trip = 0.0
        self._step_index = 0
        self._direction = 1
        self._step_timer = 0.0
        self._overheat_active = False
        self._cycles_done = 0

    def _on_start(self) -> None:
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()

    def _on_stop(self) -> None:
        thread = self._thread
        if thread is not None and thread.is_alive():
            thread.join(timeout=2.0)
        self._thread = None

    def _target_speed(self) -> float:
        return float(SPEED_STEPS[self._step_index])

    def _advance_step(self, dt: float) -> None:
        self._step_timer += dt
        if self._step_timer < STEP_HOLD_SECONDS:
            return
        self._step_timer = 0.0
        next_index = self._step_index + self._direction
        if next_index >= len(SPEED_STEPS):
            self._direction = -1
            self._cycles_done += 1
            next_index = len(SPEED_STEPS) - 2
        elif next_index < 0:
            self._direction = 1
            next_index = 1
        self._step_index = next_index

    def _throttle_factor(self) -> float:
        return self._rng.uniform(0.85, 1.15)

    def _update_engine(self, dt: float, engine_on: bool) -> None:
        target = self._target_speed()
        if not engine_on:
            self._speed = max(0.0, self._speed - BRAKE_RATE * dt)
        elif self._speed < target:
            self._speed = min(target, self._speed + ACCEL_RATE * dt * self._throttle_factor())
        else:
            self._speed = max(target, self._speed - BRAKE_RATE * dt)

        if engine_on and self._speed > 2.0:
            gear = max(min(self._step_index, len(GEAR_TOP_RPM)) - 1, 0)
            top_rpm = float(GEAR_TOP_RPM[gear])
            bottom_speed = float(SPEED_STEPS[gear])
            span_speed = max(float(SPEED_STEPS[gear + 1]) - bottom_speed, 1.0)
            progress = min(max((self._speed - bottom_speed) / span_speed, 0.0), 1.0)
            base_rpm = ENGAGE_RPM + progress * (top_rpm - ENGAGE_RPM)
            self._rpm += (base_rpm - self._rpm) * min(dt * 4.0, 1.0)
        else:
            self._rpm += (IDLE_RPM - self._rpm) * min(dt * 3.0, 1.0)

        jitter = self._rng.uniform(-60.0, 60.0) * dt
        self._rpm = min(max(self._rpm + jitter, 0.0), 8000.0)

    def _update_secondary(self, dt: float, engine_on: bool) -> None:
        load = min(self._rpm / 8000.0, 1.0)

        if engine_on:
            target_temp = 118.0 if self._overheat_active else 90.0
            if self._overheat_active and self._temperature >= 117.5:
                self._overheat_active = False
            elif not self._overheat_active and self._cycles_done >= 3 and self._rng.random() < 0.002:
                self._overheat_active = True
                self._cycles_done = 0
            rate = 1.8 if self._temperature < 90.0 else 0.6
            self._temperature += (target_temp - self._temperature) * min(rate * dt / 10.0, 1.0)
        else:
            self._temperature -= 0.15 * dt

        if engine_on:
            target_oil = 0.9 + load * 3.6
            self._oil_pressure += (target_oil - self._oil_pressure) * min(dt * 5.0, 1.0)
        else:
            self._oil_pressure = max(0.0, self._oil_pressure - dt * 4.0)

        if engine_on:
            target_volt = 13.9 + load * 0.4 + self._rng.uniform(-0.05, 0.05)
            self._battery_voltage += (target_volt - self._battery_voltage) * min(dt * 2.0, 1.0)
        else:
            self._battery_voltage = max(11.8, self._battery_voltage - dt * 0.02)

        target_vacuum = max(15.0, 68.0 - load * 45.0)
        self._vacuum += (target_vacuum - self._vacuum) * min(dt * 6.0, 1.0)

        if engine_on:
            target_amp = 12.0 + load * 14.0 + self._rng.uniform(-1.5, 1.5)
            self._amperage += (target_amp - self._amperage) * min(dt * 3.0, 1.0)
        else:
            self._amperage += (-3.0 - self._amperage) * min(dt * 2.0, 1.0)

        consumption = (self._speed / 220.0) * (0.35 + load * 0.65) * 0.09
        self._fuel_level = max(0.0, self._fuel_level - consumption * dt)
        if self._fuel_level <= 0.01 and not engine_on:
            self._fuel_level = 95.0

        self._trip += (self._speed * dt) / 3600.0

    def _collect_alerts(self, engine_on: bool) -> tuple[Alert, ...]:
        alerts: list[Alert] = []
        now = _dt.datetime.now()

        if self._temperature >= 115.0:
            alerts.append(Alert("OVERHEAT", AlertSeverity.CRITICAL, "Temperatura do motor alta", now))
        elif self._temperature >= 105.0:
            alerts.append(Alert("TEMP_HIGH", AlertSeverity.WARNING, "Temperatura elevada", now))

        if engine_on and self._oil_pressure < 0.6 and self._rpm > 1500:
            alerts.append(Alert("OIL_PRESSURE_LOW", AlertSeverity.CRITICAL, "Pressao de oleo baixa", now))

        if not engine_on and self._battery_voltage < 12.2:
            alerts.append(Alert("BATTERY_LOW", AlertSeverity.WARNING, "Bateria fraca", now))

        if self._fuel_level <= 10.0:
            alerts.append(Alert("FUEL_LOW", AlertSeverity.WARNING, "Combustivel na reserva", now))

        return tuple(alerts)

    def _snapshot(self) -> VehicleData:
        return VehicleData(
            rpm=round(self._rpm, 1),
            speed=round(self._speed, 1),
            temperature=round(self._temperature, 1),
            oil_pressure=round(self._oil_pressure, 2),
            battery_voltage=round(self._battery_voltage, 2),
            vacuum=round(self._vacuum, 1),
            amperage=round(self._amperage, 1),
            fuel_level=round(self._fuel_level, 1),
            trip=round(self._trip, 2),
            clock=_dt.datetime.now(),
            alerts=self._collect_alerts(engine_on=True),
        )

    def _run_loop(self) -> None:
        interval = 1.0 / UPDATE_HZ
        last = time.monotonic()
        while self.is_running:
            now = time.monotonic()
            dt = min(now - last, 0.25)
            last = now
            self._advance_step(dt)
            self._update_engine(dt, engine_on=True)
            self._update_secondary(dt, engine_on=True)
            self._publish(self._snapshot())
            time.sleep(interval)
