import React from "react";
import { Controller, Control } from "react-hook-form";
import { FormControl, Select, MenuItem, FormHelperText } from "@mui/material";

interface Class {
  name: string;
}

interface ClassSelectProps {
  control: Control<any>;
  classes: Class[];
}

export const ClassSelect: React.FC<ClassSelectProps> = ({ control, classes }) => (
  <Controller
    name="class"
    control={control}
    render={({
      field: { onChange, value },
      fieldState: { error },
    }) => (
      <FormControl fullWidth variant="outlined" error={!!error}>
        <Select
          labelId="class"
          value={value || ""}
          onChange={(event) => onChange(event.target.value)}
        >
          {classes.map(({ name }) => (
            <MenuItem value={name} key={name}>
              {name}
            </MenuItem>
          ))}
        </Select>
        <FormHelperText>{error?.message}</FormHelperText>
      </FormControl>
    )}
  />
);