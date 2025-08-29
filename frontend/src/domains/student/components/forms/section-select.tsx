import React from "react";
import { Controller, Control } from "react-hook-form";
import { FormControl, Select, MenuItem, FormHelperText } from "@mui/material";

interface Section {
  name: string;
}

interface SectionSelectProps {
  control: Control<any>;
  sections: Section[] | undefined;
  isLoading: boolean;
  name?: string;
}

export const SectionSelect: React.FC<SectionSelectProps> = ({
  control,
  sections,
  isLoading,
  name = "section",
}) => (
  <Controller
    name={name}
    control={control}
    render={({ field: { onChange, value }, fieldState: { error } }) => (
      <FormControl fullWidth variant="outlined" error={!!error}>
        <Select
          labelId={name}
          value={value || ""}
          onChange={(e) => onChange(e.target.value)}
        >
          {isLoading ? (
            <MenuItem disabled>Loading...</MenuItem>
          ) : (
            sections?.map(({ name }) => (
              <MenuItem value={name} key={name}>
                {name}
              </MenuItem>
            ))
          )}
        </Select>
        <FormHelperText>{error?.message}</FormHelperText>
      </FormControl>
    )}
  />
);
