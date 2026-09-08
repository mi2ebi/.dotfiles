use std::{collections::HashSet, fmt::Write as _, fs, process::exit};

fn to_slug(c: char) -> String {
    if c.is_ascii_alphanumeric() {
        return c.to_string();
    }
    match c {
        '~' => "tild",
        '`' => "grav",
        '!' => "bang",
        '@' => "aaat",
        '#' => "hash",
        '$' => "dolr",
        '%' => "pcnt",
        '^' => "cart",
        '&' => "amps",
        '*' => "star",
        '(' => "lpar",
        ')' => "rpar",
        '_' => "undr",
        '-' => "hyph",
        '+' => "plus",
        '=' => "eqal",
        '[' => "lbrk",
        '{' => "lbrc",
        ']' => "rbrk",
        '}' => "rbrc",
        '\\' => "bsla",
        '|' => "pipe",
        ';' => "semi",
        ':' => "coln",
        '\'' => "apos",
        '"' => "quot",
        '<' => "less",
        '>' => "grea",
        ',' => "coma",
        '.' => "peri",
        '/' => "slas",
        '?' => "ques",
        other => panic!("no slug defined for {other:?}"),
    }
    .to_string()
}

fn to_key(c: char) -> String {
    if c.is_ascii_lowercase() || c.is_ascii_digit() {
        return c.to_string();
    }
    if c.is_ascii_uppercase() {
        return format!("S-{}", c.to_ascii_lowercase());
    }
    match c {
        '`' => "`",
        '~' => "S-`",
        '-' => "-",
        '_' => "S--",
        '=' => "=",
        '+' => "S-=",
        '[' => "[",
        '{' => "S-[",
        ']' => "]",
        '}' => "S-]",
        '\\' => r"\",
        '|' => r"S-\",
        ';' => ";",
        ':' => "S-;",
        '\'' => "'",
        '"' => "S-'",
        ',' => ",",
        '<' => "S-,",
        '.' => ".",
        '>' => "S-.",
        '/' => "/",
        '?' => "S-/",
        '!' => "S-1",
        '@' => "S-2",
        '#' => "S-3",
        '$' => "S-4",
        '%' => "S-5",
        '^' => "S-6",
        '&' => "S-7",
        '*' => "S-8",
        '(' => "S-9",
        ')' => "S-0",
        other => panic!("no key mapping for {other:?} (us qwerty only)"),
    }
    .to_string()
}

#[allow(clippy::many_single_char_names, reason = "annoying")]
fn main() {
    let contents = fs::read_to_string("seqs.txt").expect("can't open seqs.txt");
    let mut warnings = vec![];
    let mut seen = HashSet::new();
    let mut seqs_lines = Vec::new();
    let mut entries = contents
        .lines()
        .filter_map(|line| {
            let line = line.trim().to_string();
            if line.is_empty() {
                return None;
            }
            let fields: Vec<&str> = line.split_whitespace().collect();
            if fields.len() != 2 && fields.len() != 3 {
                warnings.push(format!("expected 2 or 3 fields, got {}: {line}", fields.len()));
                return None;
            }
            let seq = fields[0];
            if !seq.chars().all(|ch| ch.is_ascii_graphic()) {
                warnings.push(format!("seq {seq} has non-graphical-ascii chars"));
            }
            if seq.len() > 4 {
                warnings.push(format!("seq {seq} is {} characters, max is 4", seq.len()));
            }
            let hexes = fields[1];
            let cps = hexes
                .split(',')
                .map(|hex| u32::from_str_radix(hex, 16))
                .collect::<Result<Vec<_>, _>>();
            let Ok(cps) = cps else {
                warnings.push(format!("{hexes} isn't valid hex codepoint list"));
                return None;
            };
            let Some(xchrs) = cps.iter().map(|&n| char::from_u32(n)).collect::<Option<Vec<_>>>()
            else {
                warnings.push(format!("{hexes} contains an invalid unicode codepoint"));
                return None;
            };
            let mut line = format!(
                "{seq} {}",
                cps.iter().map(|n| format!("{n:x}")).collect::<Vec<_>>().join(",")
            );
            if fields.len() == 3 {
                let chrs = fields[2];
                line = format!("{line} {chrs}");
                let given = chrs.chars().collect::<Vec<_>>();
                if given != xchrs {
                    warnings.push(format!(
                        "hexes {hexes} (={:?}) don't match chars {chrs:?}",
                        xchrs.iter().collect::<String>()
                    ));
                }
            }
            if !seen.insert(seq.to_string()) {
                warnings.push(format!("duplicate seq {seq}"));
            }
            seqs_lines.push((cps[0], line));
            let name = format!("seq:{}", seq.chars().map(to_slug).collect::<Vec<_>>().join("-"));
            let keys = seq.chars().map(to_key).collect::<Vec<_>>().join(" ");
            Some((name, keys, xchrs))
        })
        .collect::<Vec<_>>();
    entries.sort_by_key(|(_, _, c)| c.clone());
    if !warnings.is_empty() {
        for w in warnings {
            println!("\x1b[93m{w}\x1b[m");
        }
        exit(1);
    }
    seqs_lines.sort_by_key(|(n, _)| *n);
    let sorted_seqs =
        seqs_lines.into_iter().map(|(_, line)| line).collect::<Vec<_>>().join("\n") + "\n";
    fs::write("seqs.txt", sorted_seqs).unwrap();
    let mut out = "(defvirtualkeys\n".to_string();
    for (name, _, chars) in &entries {
        if chars.len() == 1 {
            writeln!(out, "  {name} (unicode u+{:x})", chars[0] as u32).unwrap();
        } else {
            let actions = chars
                .iter()
                .map(|c| format!("(unicode u+{:x})", *c as u32))
                .collect::<Vec<_>>()
                .join(" ");
            writeln!(out, "  {name} (macro {actions})").unwrap();
        }
    }
    out += ")\n(defseq\n";
    for (name, keys, _) in &entries {
        writeln!(out, "  {name} ({keys} nop0)").unwrap();
    }
    out += ")\n";
    fs::write("seqs.kbd", out).unwrap();
    println!("done");
}
