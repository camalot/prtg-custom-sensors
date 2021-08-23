# -*- coding: utf-8 -*-

import json
import sys

from prtg.sensor.result import CustomSensorResult
from prtg.sensor.units import ValueUnit


if __name__ == "__main__":
    try:
        data = json.loads(sys.argv[1])

        csr = CustomSensorResult(text="This sensor runs on %s" % data["host"])
        
        csr.add_primary_channel(name="Percentage",
                                value=87,
                                unit=ValueUnit.PERCENT,
                                is_float=False,
                                is_limit_mode=True,
                                limit_min_error=10,
                                limit_max_error=90,
                                limit_error_msg="Percentage too high")
                                
        csr.add_channel(name="Response Time",
                        value=4711,
                        unit=ValueUnit.TIMERESPONSE)

        print(csr.json_result)
    except Exception as e:
        csr = CustomSensorResult(text="Python Script execution error")
        csr.error = "Python Script execution error: %s" % str(e)
        print(csr.json_result)
