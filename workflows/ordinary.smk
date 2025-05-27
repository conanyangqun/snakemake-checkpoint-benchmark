# this is an ordinary workflow without checkpoint.
import time

sample_num = int(config.get('num', 1000))

def generate_tag(k):
    if k in range(1, 801):
        return 'A'
    else:
        return 'B'

samples = {
    'S{:03d}'.format(k):generate_tag(k) for k in range(1, sample_num + 1)
}


rule all:
    input:
        [
            f"out/{s}/{s}.workflow_result.txt" for s in samples
        ]
        

checkpoint genearate_tag:
    output:
        sample_tag = "out/{s}/{s}.tag.txt"
    params:
        tag = lambda wc: samples[wc['s']],
    shell:
        """
        echo -e "{wildcards.s}\t{params.tag}" >{output.sample_tag}
        """

# workflow for tag A.
rule A_step01:
    output:
        A_step01 = "out/{s}/workflowA/{s}.step01.txt"
    shell:
        """
        echo -e "{wildcards.s} workflow A step01 result." >{output.A_step01}
        """

rule A_step02:
    input:
        A_step01 = rules.A_step01.output.A_step01,
    output:
        A_step02 = "out/{s}/workflowA/{s}.step02.txt"
    shell:
        """
        echo -e "{wildcards.s} workflow A step02 result." >{output.A_step02}
        """

# workflow for tag B.
rule B_step01:
    output:
        B_step01 = "out/{s}/workflowB/{s}.step01.txt"
    shell:
        """
        echo -e "{wildcards.s} workflow B step01 result." >{output.B_step01}
        """

def collect_inputs_for_collect_workflow_result(wc):
    sample = wc['s']
    input_files = []
    tag = samples[sample]

    '''
    # to do something.
    tag_file = checkpoints.genearate_tag.get(
        s=sample
    ).output.sample_tag

    with open(tag_file) as f:
        l = next(f)
        s, tag = l.rstip('\n').split('\t')
    '''

    # output files according to tag.
    if tag == 'A':
        input_files.append(
            "out/{s}/workflowA/{s}.step02.txt"
        )
    elif tag == 'B':
        input_files.append(
            "out/{s}/workflowB/{s}.step01.txt"
        )
    else:
        raise ValueError(f'tag {tag} not processed.')
    
    return input_files

# collect workflow result.
rule collect_workflow_result:
    input:
        collect_inputs_for_collect_workflow_result
    output:
        sample_result = "out/{s}/{s}.workflow_result.txt"
    shell:
        """
        cat {input} >{output.sample_result}
        echo "workflow ends." >>{output.sample_result}
        """
