\<^marker>\<open>creator Andreas Vollert\<close>

theory IMP_Minus_To_IMP_Minus_Minus_State_Translations_IMP
  imports
    Primitives_IMP_Minus
    Binary_Arithmetic_IMP
    IMP_Minus_To_IMP_Minus_Minus_State_Translations_nat
    IMP_Minus.Com
begin

unbundle IMP_Minus_Minus_Com.no_com_syntax


subsection \<open>Useful Definitions and Lemmas\<close>

lemma Seq_E:
  "\<lbrakk>(c1;; c2, s1) \<Rightarrow>\<^bsup> p \<^esup> s3; \<And>x s2 y. \<lbrakk>(c1, s1) \<Rightarrow>\<^bsup> x \<^esup> s2; (c2, s2) \<Rightarrow>\<^bsup> y \<^esup> s3\<rbrakk> \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  by blast

abbreviation "hash_as_nat \<equiv> 35"
lemma hash_encode_val: "encode_char (CHR ''#'') = hash_as_nat"
  by (simp add: encode_char_def)

abbreviation "dollar_as_nat \<equiv> 703"
lemma dollar_encode_val: "vname_encode ''$'' = dollar_as_nat"
  by (simp add: vname_encode_def encode_char_def prod_encode_def triangle_def)

lemma hd_nat_noteq_zero: "hd_nat n \<noteq> 0 \<Longrightarrow> n > 0"
  by (induction n)
    (simp add: hd_nat_def fst_nat_def prod_decode_def prod_decode_aux.simps, simp)

method fastforce_sorted_premises uses simp =
  (match premises in
    var_doesnt_change[thin]: "\<And>x. x \<in>  _ \<Longrightarrow> _ (_ x) = _ (_ x)"(multi)
    \<Rightarrow> \<open>match premises in
        subroutine_results[thin]: "_ (add_prefix (add_prefix p _) _) = _" (multi) for p
          \<Rightarrow> \<open>match premises in
            assignments[thin]: "((add_prefix p1 _) ::= _, _) \<Rightarrow>\<^bsup> _ \<^esup> _" (multi) for p1
              \<Rightarrow> \<open>match premises in
                while_cond[thin]: "_ < _ (add_prefix p2 _)" (multi) for p2
                  \<Rightarrow> \<open>match premises in
                    invoke[thin]: "(invoke_subprogram p3 _, _) \<Rightarrow>\<^bsup> _ \<^esup> _" (multi) for p3
                      \<Rightarrow> \<open>match premises in
                        remaining[thin]: "_" (multi)
                          \<Rightarrow> \<open>insert var_doesnt_change subroutine_results while_cond invoke,
                             (fastforce simp add: assignments[THEN AssignD, simplified]
                                remaining simp)\<close>\<close>\<close>\<close>\<close>\<close>)

method sort_premises =
  (match premises in
    var_doesnt_change[thin]: "\<And>x. x \<in>  _ \<Longrightarrow> _ (_ x) = _ (_ x)"(multi)
    \<Rightarrow> \<open>match premises in
        subroutine_results[thin]: "_ (add_prefix (add_prefix p _) _) = _" (multi) for p
          \<Rightarrow> \<open>match premises in
            assignments[thin]: "((add_prefix p1 _) ::= _, _) \<Rightarrow>\<^bsup> _ \<^esup> _" (multi) for p1
              \<Rightarrow> \<open>match premises in
                while_cond[thin]: "_ < _ (add_prefix p2 _)" (multi) for p2
                  \<Rightarrow> \<open>match premises in
                    invoke[thin]: "(invoke_subprogram p3 _, _) \<Rightarrow>\<^bsup> _ \<^esup> _" (multi) for p3
                      \<Rightarrow> \<open>match premises in
                    remaining[thin]: "_" (multi)
                      \<Rightarrow> \<open>insert var_doesnt_change subroutine_results while_cond invoke assignments
                          remaining\<close>\<close>\<close>\<close>\<close>\<close>)

subsection \<open>dropWhile_char\<close>

subsubsection \<open>dropWhile_char_loop\<close>

record dropWhile_char_loop_state =
  dropWhile_char_loop_n::nat
  dropWhile_char_loop_ret::nat

abbreviation "dropWhile_char_loop_prefix \<equiv> ''dropWhile_char_loop.''"
abbreviation "dropWhile_char_loop_n_str \<equiv> ''n''"
abbreviation "dropWhile_char_loop_ret_str \<equiv> ''ret''"

function dropWhile_char_loop:: "nat \<Rightarrow> nat" where
  "dropWhile_char_loop n =
 (if hd_nat n = encode_char (CHR ''#'')
          then dropWhile_char_loop (tl_nat n)
          else n
    )"
  by simp+
termination
  by (relation "measure id", simp)
    (simp add: hash_encode_val pos_tl_less hd_nat_noteq_zero)

definition "dropWhile_char_loop_state_upd s \<equiv>
      let
        tl_xs' = dropWhile_char_loop_n s;
        tl_ret' = 0;
        tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;
        tl_ret_state = tl_imp tl_state;
        dropWhile_char_loop_n' = tl_ret tl_ret_state;
        dropWhile_char_loop_ret' = dropWhile_char_loop_ret s;
        ret = \<lparr>dropWhile_char_loop_n = dropWhile_char_loop_n',
               dropWhile_char_loop_ret = dropWhile_char_loop_ret'\<rparr>
      in
        ret"

definition "dropWhile_char_loop_imp_compute_loop_condition s \<equiv>
  (let hd_xs' = dropWhile_char_loop_n s;
       hd_ret' = 0;
       hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
       hd_ret_state = hd_imp hd_state;
       EQUAL_neq_zero_a' = hd_ret hd_ret_state;
       EQUAL_neq_zero_b' = hash_as_nat;
       EQUAL_neq_zero_ret' = 0;
       EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',
                               EQUAL_neq_zero_b = EQUAL_neq_zero_b',
                               EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;
       EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;
       condition = EQUAL_neq_zero_ret EQUAL_neq_zero_ret_state
   in condition
  )"

definition "dropWhile_char_loop_imp_after_loop s \<equiv>
  (let
    dropWhile_char_loop_n' = dropWhile_char_loop_n s;
    dropWhile_char_loop_ret' = dropWhile_char_loop_n s;
    ret = \<lparr>dropWhile_char_loop_n = dropWhile_char_loop_n',
           dropWhile_char_loop_ret = dropWhile_char_loop_ret'\<rparr>
   in ret
  )"

lemmas dropWhile_char_loop_imp_subprogram_simps =
  dropWhile_char_loop_imp_after_loop_def
  dropWhile_char_loop_state_upd_def
  dropWhile_char_loop_imp_compute_loop_condition_def

function dropWhile_char_loop_imp:: "dropWhile_char_loop_state \<Rightarrow> dropWhile_char_loop_state" where
  "dropWhile_char_loop_imp s =
  (if dropWhile_char_loop_imp_compute_loop_condition s \<noteq> 0
         then (let next_iteration = dropWhile_char_loop_imp (dropWhile_char_loop_state_upd s)
               in next_iteration)
         else (let ret = dropWhile_char_loop_imp_after_loop s in ret))"
  by simp+
termination
  by (relation "measure dropWhile_char_loop_n", simp)
    (simp add: dropWhile_char_loop_imp_subprogram_simps tl_imp_correct EQUAL_neq_zero_imp_correct
      hd_imp_correct split:if_splits, simp only: hd_nat_noteq_zero pos_tl_less)

declare dropWhile_char_loop_imp.simps [simp del]

lemma dropWhile_char_loop_imp_correct:
  "dropWhile_char_loop_ret (dropWhile_char_loop_imp s) =
    dropWhile_char_loop (dropWhile_char_loop_n s)"
  by (induction "dropWhile_char_loop_n s" arbitrary: s rule: dropWhile_char_loop.induct)
    (subst dropWhile_char_loop_imp.simps, simp add: dropWhile_char_loop_imp_subprogram_simps
      tl_imp_correct hd_imp_correct EQUAL_neq_zero_imp_correct hash_encode_val)

definition "dropWhile_char_loop_state_upd_time t s \<equiv>
      let
        tl_xs' = dropWhile_char_loop_n s;
        t = t + 2;
        tl_ret' = 0;
        t = t + 2;
        tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;
        tl_ret_state = tl_imp tl_state;
        t = t + tl_imp_time 0 tl_state;
        dropWhile_char_loop_n' = tl_ret tl_ret_state;
        t = t + 2;
        dropWhile_char_loop_ret' = dropWhile_char_loop_ret s;
        t = t + 2;
        ret = t
      in
        ret"

definition "dropWhile_char_loop_imp_compute_loop_condition_time t s \<equiv>
  (let hd_xs' = dropWhile_char_loop_n s;
       t = t + 2;
       hd_ret' = 0;
       t = t + 2;
       hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
       hd_ret_state = hd_imp hd_state;
       t = t + hd_imp_time 0 hd_state;
       EQUAL_neq_zero_a' = hd_ret hd_ret_state;
       t = t + 2;
       EQUAL_neq_zero_b' = hash_as_nat;
       t = t + 2;
       EQUAL_neq_zero_ret' = 0;
       t = t + 2;
       EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',
                               EQUAL_neq_zero_b = EQUAL_neq_zero_b',
                               EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;
       EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;
       t = t + EQUAL_neq_zero_imp_time 0 EQUAL_neq_zero_state;
       condition = EQUAL_neq_zero_ret EQUAL_neq_zero_ret_state;
       t = t + 2;
       ret = t
   in ret
  )"

definition "dropWhile_char_loop_imp_after_loop_time (t::nat) (s::dropWhile_char_loop_state) \<equiv>
  (let
    dropWhile_char_n' = dropWhile_char_loop_n s;
    t = t + 2;
    dropWhile_char_ret' = dropWhile_char_loop_n s;
    t = t + 2;
    ret = t
   in ret
  )"

lemmas dropWhile_char_loop_imp_subprogram_simps_time =
  dropWhile_char_loop_imp_after_loop_time_def
  dropWhile_char_loop_state_upd_time_def
  dropWhile_char_loop_imp_compute_loop_condition_time_def

function dropWhile_char_loop_imp_time:: "nat \<Rightarrow> dropWhile_char_loop_state \<Rightarrow> nat" where
  "dropWhile_char_loop_imp_time t s =
   dropWhile_char_loop_imp_compute_loop_condition_time 0 s +
  (if dropWhile_char_loop_imp_compute_loop_condition s \<noteq> 0
   then
    (let
        t = t + 1;
        next_iteration
          = dropWhile_char_loop_imp_time (t + dropWhile_char_loop_state_upd_time 0 s)
                                         (dropWhile_char_loop_state_upd s)
     in next_iteration)
  else
    (let
        t = t + 2;
        ret = t + dropWhile_char_loop_imp_after_loop_time 0 s
     in ret)
  )"
  by auto
termination
  apply (relation "measure (dropWhile_char_loop_n \<circ> snd)", simp)
  apply (subst dropWhile_char_loop_state_upd_def)
  apply (simp add: dropWhile_char_loop_imp_compute_loop_condition_def tl_imp_correct
      EQUAL_neq_zero_imp_correct hd_imp_correct split: if_splits)
  by (simp only: pos_tl_less hd_nat_noteq_zero)

declare dropWhile_char_loop_imp_time.simps [simp del]

lemmas dropWhile_char_loop_imp_subprogram_time_simps =
  dropWhile_char_loop_imp_subprogram_simps
  dropWhile_char_loop_imp_after_loop_time_def
  dropWhile_char_loop_state_upd_time_def
  dropWhile_char_loop_imp_compute_loop_condition_time_def

lemma dropWhile_char_loop_imp_time_acc:
  "(dropWhile_char_loop_imp_time (Suc t) s) = Suc (dropWhile_char_loop_imp_time t s)"
  by (induction t s rule: dropWhile_char_loop_imp_time.induct)
    ((subst (1 2) dropWhile_char_loop_imp_time.simps);
      (simp add: dropWhile_char_loop_state_upd_def))

lemma dropWhile_char_loop_imp_time_acc_2_aux:
  "(dropWhile_char_loop_imp_time t s) =
    t + (dropWhile_char_loop_imp_time 0 s)"
  by (induction t arbitrary: s)
    (simp add: dropWhile_char_loop_imp_time_acc)+

lemma dropWhile_char_loop_imp_time_acc_2:
  "t \<noteq> 0 \<Longrightarrow> (dropWhile_char_loop_imp_time t s) =
    t + (dropWhile_char_loop_imp_time 0 s)"
  by (rule dropWhile_char_loop_imp_time_acc_2_aux)

lemma dropWhile_char_loop_imp_time_acc_3:
  "(dropWhile_char_loop_imp_time (a + b) s) =
    a + (dropWhile_char_loop_imp_time b s)"
  by (induction a arbitrary: b s)
    (simp add: dropWhile_char_loop_imp_time_acc)+

abbreviation "dropWhile_char_loop_while_cond \<equiv> ''condition''"

definition "dropWhile_char_loop_IMP_init_while_cond \<equiv>
  (hd_prefix @ hd_xs_str) ::= (A (V dropWhile_char_loop_n_str));;
  \<comment> \<open>(hd_ret' = 0;\<close>
  (hd_prefix @ hd_ret_str) ::= (A (N 0));;
  \<comment> \<open>(hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;\<close>
  \<comment> \<open>(hd_ret_state = hd_imp hd_state;\<close>
  invoke_subprogram hd_prefix hd_IMP_Minus;;
  \<comment> \<open>(EQUAL_neq_zero_a' = hd_ret hd_ret_state;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_a_str) ::= (A (V (hd_prefix @ hd_ret_str)));;
  \<comment> \<open>(EQUAL_neq_zero_b' = hash_as_nat;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_b_str) ::= (A (N hash_as_nat));;
  \<comment> \<open>(EQUAL_neq_zero_ret' = 0;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_ret_str) ::= (A (N 0));;
  \<comment> \<open>(EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',\<close>
  \<comment> \<open>(                       EQUAL_neq_zero_b = EQUAL_neq_zero_b',\<close>
  \<comment> \<open>(                       EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;\<close>
  \<comment> \<open>(EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;\<close>
  invoke_subprogram EQUAL_neq_zero_prefix EQUAL_neq_zero_IMP_Minus;;
  dropWhile_char_loop_while_cond ::= (A (V (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_ret_str)))
  "

definition "dropWhile_char_loop_IMP_loop_body \<equiv>
  \<comment> \<open>tl_xs' = dropWhile_char_loop_n s;\<close>
  (tl_prefix @ tl_xs_str) ::= (A (V dropWhile_char_loop_n_str));;
  \<comment> \<open>tl_ret' = 0;\<close>
  (tl_prefix @ tl_ret_str) ::= (A (N 0));;
  \<comment> \<open>tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;\<close>
  \<comment> \<open>tl_ret_state = tl_imp tl_state;\<close>
  invoke_subprogram tl_prefix tl_IMP_Minus;;
  \<comment> \<open>dropWhile_char_loop_n' = tl_ret tl_ret_state;\<close>
  dropWhile_char_loop_n_str ::= (A (V (tl_prefix @ tl_ret_str)));;
  \<comment> \<open>dropWhile_char_loop_ret' = dropWhile_char_ret s;\<close>
  dropWhile_char_loop_ret_str ::= (A (V dropWhile_char_loop_ret_str))
  "

definition "dropWhile_char_loop_IMP_after_loop \<equiv>
  \<comment> \<open>  dropWhile_char_loop_n' = dropWhile_char_loop_n s;\<close>
  dropWhile_char_loop_n_str ::= (A (V dropWhile_char_loop_n_str));;
  \<comment> \<open>  dropWhile_char_loop_ret' = dropWhile_char_loop_n s;\<close>
  dropWhile_char_loop_ret_str ::= (A (V dropWhile_char_loop_n_str))
  "

definition dropWhile_char_loop_IMP_Minus where
  "dropWhile_char_loop_IMP_Minus \<equiv>
  dropWhile_char_loop_IMP_init_while_cond;;
  WHILE dropWhile_char_loop_while_cond \<noteq>0 DO (
    dropWhile_char_loop_IMP_loop_body;;
    dropWhile_char_loop_IMP_init_while_cond
  );;
  dropWhile_char_loop_IMP_after_loop"

abbreviation
  "dropWhile_char_loop_IMP_vars \<equiv>
  {dropWhile_char_loop_n_str, dropWhile_char_loop_ret_str}"

lemmas dropWhile_char_loop_IMP_subprogram_simps =
  dropWhile_char_loop_IMP_init_while_cond_def
  dropWhile_char_loop_IMP_loop_body_def
  dropWhile_char_loop_IMP_after_loop_def

definition "dropWhile_char_loop_imp_to_HOL_state p s =
  \<lparr>dropWhile_char_loop_n = (s (add_prefix p dropWhile_char_loop_n_str)),
   dropWhile_char_loop_ret = (s (add_prefix p dropWhile_char_loop_ret_str))\<rparr>"

lemmas dropWhile_char_loop_state_translators =
  hd_imp_to_HOL_state_def
  tl_imp_to_HOL_state_def
  dropWhile_char_loop_imp_to_HOL_state_def
  AND_neq_zero_imp_to_HOL_state_def
  EQUAL_neq_zero_imp_to_HOL_state_def
  NOTEQUAL_neq_zero_imp_to_HOL_state_def

lemmas dropWhile_char_loop_complete_simps =
  dropWhile_char_loop_IMP_subprogram_simps
  dropWhile_char_loop_imp_subprogram_simps
  dropWhile_char_loop_state_translators

lemmas dropWhile_char_loop_complete_time_simps =
  dropWhile_char_loop_imp_subprogram_time_simps
  dropWhile_char_loop_imp_time_acc_2
  dropWhile_char_loop_imp_time_acc_3
  dropWhile_char_loop_state_translators

lemma dropWhile_char_loop_IMP_Minus_correct_function:
  "(invoke_subprogram p dropWhile_char_loop_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p dropWhile_char_loop_ret_str) =
       dropWhile_char_loop_ret (dropWhile_char_loop_imp (dropWhile_char_loop_imp_to_HOL_state p s))"
  apply(induction "dropWhile_char_loop_imp_to_HOL_state p s" arbitrary: s s' t
      rule: dropWhile_char_loop_imp.induct)
  apply(subst dropWhile_char_loop_imp.simps)
  apply(simp only: dropWhile_char_loop_IMP_Minus_def prefix_simps)

  apply(erule Seq_E)+
  apply(erule While_tE)
  subgoal
    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(13) by fastforce
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(15) by fastforce
    by(force simp: dropWhile_char_loop_complete_simps Let_def)

  apply(erule Seq_E)+
  apply(dest_com_gen)

  subgoal
    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(20) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(22) by fastforce
    by(fastforce_sorted_premises simp: dropWhile_char_loop_complete_simps Let_def)

  subgoal

    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps
        dropWhile_char_loop_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(24) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(26) by fastforce
    apply(erule tl_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(28) by fastforce
    by(fastforce_sorted_premises simp: dropWhile_char_loop_complete_simps Let_def)

  subgoal
    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps
        dropWhile_char_loop_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(24) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(26) by fastforce
    apply(erule tl_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(28) by fastforce
    by(fastforce_sorted_premises simp: dropWhile_char_loop_complete_simps Let_def)

  done

lemma dropWhile_char_loop_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ dropWhile_char_loop_pref) dropWhile_char_loop_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix dropWhile_char_loop_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma dropWhile_char_loop_IMP_Minus_correct_time_loop_condition:
  "(invoke_subprogram p dropWhile_char_loop_IMP_init_while_cond, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = dropWhile_char_loop_imp_compute_loop_condition_time
          0 (dropWhile_char_loop_imp_to_HOL_state p s)"
  by (fastforce elim: EQUAL_neq_zero_IMP_Minus_correct hd_IMP_Minus_correct simp: Let_def
      dropWhile_char_loop_imp_compute_loop_condition_time_def invoke_subprogram_append
      dropWhile_char_loop_IMP_init_while_cond_def EQUAL_neq_zero_IMP_Minus_correct_time
      dropWhile_char_loop_imp_subprogram_simps dropWhile_char_loop_imp_time_acc
      dropWhile_char_loop_state_translators)

lemma dropWhile_char_loop_IMP_Minus_correct_time:
  "(invoke_subprogram p dropWhile_char_loop_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = dropWhile_char_loop_imp_time 0 (dropWhile_char_loop_imp_to_HOL_state p s)"
  apply(induction "dropWhile_char_loop_imp_to_HOL_state p s" arbitrary: s s' t
      rule: dropWhile_char_loop_imp.induct)
  apply(subst dropWhile_char_loop_imp_time.simps)
  apply(simp only: dropWhile_char_loop_IMP_Minus_def prefix_simps)

  apply(erule Seq_tE)+
  apply(erule While_tE_time)
  subgoal
    apply(simp only: dropWhile_char_loop_IMP_subprogram_simps prefix_simps)
    apply(erule Seq_tE)+
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(24) by fastforce
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(26) by fastforce
    by (force simp: dropWhile_char_loop_imp_subprogram_time_simps Let_def
        dropWhile_char_loop_state_translators)

  apply(erule Seq_tE)+
  apply(simp add: add.assoc)
  apply(dest_com_gen_time)

  subgoal
    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_tE)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(37) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(39) by fastforce
    by (fastforce_sorted_premises simp: dropWhile_char_loop_complete_simps Let_def)

  subgoal

    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps
        dropWhile_char_loop_IMP_loop_body_def)
    apply(erule Seq_tE)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(45) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(47) by fastforce
    apply(erule tl_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(49) by fastforce
    by (fastforce_sorted_premises simp: Let_def dropWhile_char_loop_complete_time_simps)

  subgoal
    apply(simp only: dropWhile_char_loop_IMP_init_while_cond_def prefix_simps
        dropWhile_char_loop_IMP_loop_body_def)
    apply(erule Seq_tE)+
    apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(45) by fastforce
    apply(erule hd_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(47) by fastforce
    apply(erule tl_IMP_Minus_correct[where vars = "dropWhile_char_loop_IMP_vars"])
    subgoal premises p using p(49) by fastforce
    by (fastforce_sorted_premises simp: dropWhile_char_loop_complete_time_simps Let_def)

  done

lemma dropWhile_char_loop_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) dropWhile_char_loop_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
    \<lbrakk>t = (dropWhile_char_loop_imp_time 0 (dropWhile_char_loop_imp_to_HOL_state (p1 @ p2) s));
     s' (add_prefix (p1 @ p2) dropWhile_char_loop_ret_str) =
      dropWhile_char_loop_ret (dropWhile_char_loop_imp
                                (dropWhile_char_loop_imp_to_HOL_state (p1 @ p2) s));
     \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk> \<Longrightarrow> P\<rbrakk>
  \<Longrightarrow> P"
  using dropWhile_char_loop_IMP_Minus_correct_function
  by (auto simp: dropWhile_char_loop_IMP_Minus_correct_time)
    (meson dropWhile_char_loop_IMP_Minus_correct_effects set_mono_prefix)


subsubsection \<open>dropWhile_char\<close>

record dropWhile_char_state =
  dropWhile_char_n::nat
  dropWhile_char_ret::nat

abbreviation "dropWhile_char_prefix \<equiv> ''dropWhile_char_loop.''"
abbreviation "dropWhile_char_n_str \<equiv> ''n''"
abbreviation "dropWhile_char_ret_str \<equiv> ''ret''"

fun dropWhile_char':: "nat \<Rightarrow> nat" where
  "dropWhile_char' n =
  (if n \<noteq> 0
   then dropWhile_char_loop n
   else n)"

lemma dropWhile_char'_correct: "dropWhile_char n = dropWhile_char' n"
  by (induction n rule: dropWhile_char.induct)
    (simp add: fst_nat_0 hash_encode_val hd_nat_def split: if_splits)

definition "dropWhile_char_state_upd s \<equiv>
      let
        dropWhile_char_loop_n' = dropWhile_char_n s;
        dropWhile_char_loop_ret' = 0;
        dropWhile_char_loop_state = \<lparr>dropWhile_char_loop_n = dropWhile_char_loop_n',
                                     dropWhile_char_loop_ret = dropWhile_char_loop_ret'\<rparr>;
        dropWhile_char_loop_ret_state = dropWhile_char_loop_imp dropWhile_char_loop_state;
        dropWhile_char_n' = dropWhile_char_n s;
        dropWhile_char_ret' = dropWhile_char_loop_ret dropWhile_char_loop_ret_state;
        ret = \<lparr>dropWhile_char_n = dropWhile_char_n',
               dropWhile_char_ret = dropWhile_char_ret'\<rparr>
      in
        ret"

fun dropWhile_char_imp:: "dropWhile_char_state \<Rightarrow> dropWhile_char_state" where
  "dropWhile_char_imp s =
  (if dropWhile_char_n s \<noteq> 0
   then dropWhile_char_state_upd s
   else \<lparr>dropWhile_char_n = dropWhile_char_n s,
        dropWhile_char_ret = dropWhile_char_n s\<rparr>)"

declare dropWhile_char_imp.simps [simp del]

lemma dropWhile_char_imp_correct:
  "dropWhile_char_ret (dropWhile_char_imp s) = dropWhile_char' (dropWhile_char_n s)"
  by(simp add: dropWhile_char_imp.simps dropWhile_char_state_upd_def Let_def
      dropWhile_char_loop_imp_correct)

lemmas dropWhile_char_imp_subprogram_simps = dropWhile_char_state_upd_def

definition "dropWhile_char_state_upd_time t s \<equiv>
      let
        dropWhile_char_loop_n' = dropWhile_char_n s;
        t = t + 2;
        dropWhile_char_loop_ret' = 0;
        t = t + 2;
        dropWhile_char_loop_state = \<lparr>dropWhile_char_loop_n = dropWhile_char_loop_n',
                                     dropWhile_char_loop_ret = dropWhile_char_loop_ret'\<rparr>;
        dropWhile_char_loop_ret_state = dropWhile_char_loop_imp dropWhile_char_loop_state;
        t = t + dropWhile_char_loop_imp_time 0 dropWhile_char_loop_state;
        dropWhile_char_n' = dropWhile_char_n s;
        t = t + 2;
        dropWhile_char_ret' = dropWhile_char_loop_ret dropWhile_char_loop_ret_state;
        t = t + 2;
        ret = t
      in
        ret"

fun dropWhile_char_imp_time:: "nat \<Rightarrow> dropWhile_char_state \<Rightarrow> nat" where
  "dropWhile_char_imp_time t s =
  (if dropWhile_char_n s \<noteq> 0
   then (let t = t + 1;
             next = dropWhile_char_state_upd s;
             t = t + dropWhile_char_state_upd_time 0 s;
             ret = t
         in ret)
   else (let t = t + 1;
             dropWhile_char_n' = dropWhile_char_n s;
             t = t + 2;
             dropWhile_char_ret' = dropWhile_char_n s;
             t = t + 2;
             ret = t
         in ret))"

declare dropWhile_char_imp_time.simps [simp del]

lemmas dropWhile_char_imp_subprogram_simps_time = dropWhile_char_state_upd_time_def

lemma dropWhile_char_imp_time_acc:
  "(dropWhile_char_imp_time (Suc t) s) = Suc (dropWhile_char_imp_time t s)"
  by (induction t s rule: dropWhile_char_imp_time.induct)
    (simp add: dropWhile_char_imp_time.simps)

lemma dropWhile_char_imp_time_acc_2:
  "(dropWhile_char_imp_time x s) = x + (dropWhile_char_imp_time 0 s)"
  by (induction x arbitrary: s) (simp add: dropWhile_char_imp_time_acc)+

lemma dropWhile_char_imp_time_acc_2_simp:
  "(dropWhile_char_imp_time (dropWhile_char_state_upd_time 0 s) s') =
   (dropWhile_char_state_upd_time 0 s) + (dropWhile_char_imp_time 0 s')"
  by (rule dropWhile_char_imp_time_acc_2)

lemmas dropWhile_char_complete_time_simps =
  dropWhile_char_imp_subprogram_simps
  dropWhile_char_state_upd_time_def
  dropWhile_char_imp_time_acc
  dropWhile_char_imp_time_acc_2_simp

definition dropWhile_char_IMP_Minus where
  "dropWhile_char_IMP_Minus \<equiv>
  IF dropWhile_char_n_str \<noteq>0
  THEN (
    (dropWhile_char_loop_prefix @ dropWhile_char_loop_n_str) ::= (A (V dropWhile_char_n_str));;
    (dropWhile_char_loop_prefix @ dropWhile_char_loop_ret_str) ::= (A (N 0));;
    invoke_subprogram dropWhile_char_loop_prefix dropWhile_char_loop_IMP_Minus;;
    dropWhile_char_n_str ::= (A (V dropWhile_char_n_str));;
    dropWhile_char_ret_str ::= (A (V (dropWhile_char_loop_prefix @ dropWhile_char_loop_ret_str)))
  )
  ELSE (
    dropWhile_char_n_str ::= (A (V dropWhile_char_n_str));;
    dropWhile_char_ret_str ::= (A (V dropWhile_char_n_str))
  )"

abbreviation
  "dropWhile_char_IMP_vars \<equiv>
  {dropWhile_char_n_str, dropWhile_char_ret_str}"

definition "dropWhile_char_imp_to_HOL_state p s =
  \<lparr>dropWhile_char_n = (s (add_prefix p dropWhile_char_n_str)),
   dropWhile_char_ret = (s (add_prefix p dropWhile_char_ret_str))\<rparr>"

lemmas dropWhile_char_state_translators =
  dropWhile_char_imp_to_HOL_state_def
  dropWhile_char_loop_imp_to_HOL_state_def

lemmas dropWhile_char_complete_simps =
  dropWhile_char_imp_subprogram_simps
  dropWhile_char_state_translators

lemma dropWhile_char_IMP_Minus_correct_function:
  "(invoke_subprogram p dropWhile_char_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p dropWhile_char_ret_str) =
       dropWhile_char_ret (dropWhile_char_imp (dropWhile_char_imp_to_HOL_state p s))"
  by (fastforce elim: dropWhile_char_loop_IMP_Minus_correct simp: dropWhile_char_IMP_Minus_def
      dropWhile_char_complete_simps invoke_subprogram_append dropWhile_char_imp.simps)

lemma dropWhile_char_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ dropWhile_char_pref) dropWhile_char_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix dropWhile_char_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma dropWhile_char_IMP_Minus_correct_time:
  "(invoke_subprogram p dropWhile_char_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = dropWhile_char_imp_time 0 (dropWhile_char_imp_to_HOL_state p s)"
  by (fastforce elim: dropWhile_char_loop_IMP_Minus_correct simp: dropWhile_char_imp_time.simps
      dropWhile_char_IMP_Minus_def invoke_subprogram_append dropWhile_char_complete_time_simps
      dropWhile_char_state_translators Let_def)

lemma dropWhile_char_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) dropWhile_char_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (dropWhile_char_imp_time 0 (dropWhile_char_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) dropWhile_char_ret_str) =
        dropWhile_char_ret (dropWhile_char_imp (dropWhile_char_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using dropWhile_char_IMP_Minus_correct_function
  by (auto simp: dropWhile_char_IMP_Minus_correct_time)
    (meson dropWhile_char_IMP_Minus_correct_effects set_mono_prefix)


subsection \<open>n_hashes\<close>

subsubsection \<open>n_hashes_acc\<close>

record n_hashes_acc_state =
  n_hashes_acc_acc::nat
  n_hashes_acc_n::nat
  n_hashes_acc_ret::nat

abbreviation "n_hashes_acc_prefix \<equiv> ''n_hashes_acc.''"
abbreviation "n_hashes_acc_acc_str \<equiv> ''acc''"
abbreviation "n_hashes_acc_n_str \<equiv> ''n''"
abbreviation "n_hashes_acc_ret_str \<equiv> ''ret''"

definition "n_hashes_acc_state_upd s \<equiv>
      let
        cons_h' = hash_as_nat;
        cons_t' = n_hashes_acc_acc s;
        cons_ret' = 0;
        cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
        cons_ret_state = cons_imp cons_state;
        n_hashes_acc_acc' = cons_ret cons_ret_state;
        n_hashes_acc_n' = n_hashes_acc_n s - 1;
        ret = \<lparr>n_hashes_acc_acc = n_hashes_acc_acc',
               n_hashes_acc_n = n_hashes_acc_n',
               n_hashes_acc_ret = n_hashes_acc_ret s\<rparr>
      in
        ret
"

definition "n_hashes_acc_imp_compute_loop_condition s \<equiv>
  (let
    condition = n_hashes_acc_n s
   in condition
  )"

definition "n_hashes_acc_imp_after_loop s \<equiv>
  (let
    ret = \<lparr>n_hashes_acc_acc = n_hashes_acc_acc s,
           n_hashes_acc_n = n_hashes_acc_n s,
           n_hashes_acc_ret = n_hashes_acc_acc s\<rparr>
   in ret
  )"

lemmas n_hashes_acc_imp_subprogram_simps =
  n_hashes_acc_imp_after_loop_def
  n_hashes_acc_state_upd_def
  n_hashes_acc_imp_compute_loop_condition_def

function n_hashes_acc_imp:: "n_hashes_acc_state \<Rightarrow> n_hashes_acc_state" where
  "n_hashes_acc_imp s =
  (if n_hashes_acc_imp_compute_loop_condition s \<noteq> 0
   then
    (let next_iteration = n_hashes_acc_imp (n_hashes_acc_state_upd s)
      in next_iteration)
  else
    (let ret = n_hashes_acc_imp_after_loop s in ret)
  )"
  by simp+
termination by (relation "measure (\<lambda>s. n_hashes_acc_n s)")
    (simp add: n_hashes_acc_imp_subprogram_simps)+

declare n_hashes_acc_imp.simps [simp del]

lemma n_hashes_acc_imp_correct:
  "n_hashes_acc_ret (n_hashes_acc_imp s) = n_hashes_acc (n_hashes_acc_acc s) (n_hashes_acc_n s)"
  apply(induction s rule: n_hashes_acc_imp.induct)
  apply(subst n_hashes_acc_imp.simps)
  apply(simp add: n_hashes_acc_imp_subprogram_simps cons_imp_correct hash_encode_val Suc_diff_Suc)
  by (metis Suc_pred hash_encode_val n_hashes_acc.simps(2))

definition "n_hashes_acc_state_upd_time t s \<equiv>
      let
        cons_h' = hash_as_nat;
        t = t + 2;
        cons_t' = n_hashes_acc_acc s;
        t = t + 2;
        cons_ret' = 0;
        t = t + 2;
        cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
        cons_ret_state = cons_imp cons_state;
        t = t + cons_imp_time 0 cons_state;
        n_hashes_acc_acc' = cons_ret cons_ret_state;
        t = t + 2;
        n_hashes_acc_n' = n_hashes_acc_n s - 1;
        t = t + 2;
        ret = t
      in
        ret
"

definition "n_hashes_acc_imp_compute_loop_condition_time t s \<equiv>
  (let
    condition = n_hashes_acc_n s;
    t = t + 2;
    ret = t
   in ret
  )"

definition "n_hashes_acc_imp_after_loop_time t s \<equiv>
  (let
    t = t + 2;
    ret = t
   in ret
  )"

function n_hashes_acc_imp_time:: "nat \<Rightarrow> n_hashes_acc_state \<Rightarrow> nat" where
  "n_hashes_acc_imp_time t s =
  n_hashes_acc_imp_compute_loop_condition_time 0 s +
  (if n_hashes_acc_imp_compute_loop_condition s \<noteq> 0
   then
    (let
        t = t + 1;
        next_iteration
          = n_hashes_acc_imp_time (t + n_hashes_acc_state_upd_time 0 s) (n_hashes_acc_state_upd s)
     in next_iteration)
  else
    (let
        t = t + 2;
        ret = t + n_hashes_acc_imp_after_loop_time 0 s
     in ret)
  )"
  by auto
termination
  by (relation "measure (\<lambda>(t,s). n_hashes_acc_n s)")
    (simp add: n_hashes_acc_imp_subprogram_simps)+

lemmas n_hashes_acc_imp_subprogram_time_simps =
  n_hashes_acc_imp_subprogram_simps
  n_hashes_acc_imp_after_loop_time_def
  n_hashes_acc_state_upd_time_def
  n_hashes_acc_imp_compute_loop_condition_time_def

lemmas [simp del] = n_hashes_acc_imp_time.simps

lemma n_hashes_acc_imp_time_acc:
  "(n_hashes_acc_imp_time (Suc t) s) = Suc (n_hashes_acc_imp_time t s)"
  by (induction t s rule: n_hashes_acc_imp_time.induct)
    ((subst (1 2) n_hashes_acc_imp_time.simps); (simp add: n_hashes_acc_state_upd_def))

lemma n_hashes_acc_imp_time_acc_2_aux:
  "(n_hashes_acc_imp_time t s) = t + (n_hashes_acc_imp_time 0 s)"
  by (induction t arbitrary: s) (simp add: n_hashes_acc_imp_time_acc)+

lemma n_hashes_acc_imp_time_acc_2:
  "t \<noteq> 0 \<Longrightarrow> (n_hashes_acc_imp_time t s) = t + (n_hashes_acc_imp_time 0 s)"
  by (rule n_hashes_acc_imp_time_acc_2_aux)

lemma n_hashes_acc_imp_time_acc_3:
  "(n_hashes_acc_imp_time (a + b) s) = a + (n_hashes_acc_imp_time b s)"
  by (induction a arbitrary: b s) (simp add: n_hashes_acc_imp_time_acc)+

abbreviation "n_hashes_acc_while_cond \<equiv> ''condition''"

definition "n_hashes_acc_IMP_init_while_cond \<equiv>
  \<comment> \<open>condition = n_hashes_n s\<close>
  n_hashes_acc_while_cond ::= (A (V n_hashes_acc_n_str))"

definition "n_hashes_acc_IMP_loop_body \<equiv>
  \<comment> \<open>cons_h' = hash_as_nat;\<close>
  ((cons_prefix @ cons_h_str) ::= (A (N 35)));;
  \<comment> \<open>cons_t' = n_hashes_acc_acc s;\<close>
  ((cons_prefix @ cons_t_str) ::= (A (V n_hashes_acc_acc_str)));;
  \<comment> \<open>cons_ret' = 0;\<close>
  ((cons_prefix @ cons_ret_str) ::= (A (N 0)));;
  \<comment> \<open>cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;\<close>
  \<comment> \<open>cons_ret_state = cons_imp cons_state;\<close>
  (invoke_subprogram cons_prefix cons_IMP_Minus);;
  \<comment> \<open>n_hashes_acc_acc' = cons_ret cons_ret_state;\<close>
  ((n_hashes_acc_acc_str) ::= (A (V (cons_prefix @ cons_ret_str))));;
  \<comment> \<open>n_hashes_acc_n' = n_hashes_acc_n s - 1\<close>
  ((n_hashes_acc_n_str) ::= (Sub (V n_hashes_acc_n_str) (N 1)))"

definition "n_hashes_acc_IMP_after_loop \<equiv>
  \<comment> \<open>ret = s\<close>
  ((n_hashes_acc_ret_str) ::= (A (V n_hashes_acc_acc_str)))"

definition n_hashes_acc_IMP_Minus where
  "n_hashes_acc_IMP_Minus \<equiv>
  n_hashes_acc_IMP_init_while_cond;;
  WHILE n_hashes_acc_while_cond \<noteq>0 DO (
    n_hashes_acc_IMP_loop_body;;
    n_hashes_acc_IMP_init_while_cond
  );;
  n_hashes_acc_IMP_after_loop"

abbreviation
  "n_hashes_acc_IMP_vars \<equiv>
  {n_hashes_acc_acc_str, n_hashes_acc_n_str, n_hashes_acc_ret_str}"

lemmas n_hashes_acc_IMP_subprogram_simps =
  n_hashes_acc_IMP_init_while_cond_def
  n_hashes_acc_IMP_loop_body_def
  n_hashes_acc_IMP_after_loop_def

definition "n_hashes_acc_imp_to_HOL_state p s =
  \<lparr>n_hashes_acc_acc = (s (add_prefix p n_hashes_acc_acc_str)),
   n_hashes_acc_n = (s (add_prefix p n_hashes_acc_n_str)),
   n_hashes_acc_ret = (s (add_prefix p n_hashes_acc_ret_str))\<rparr>"

lemmas n_hashes_acc_state_translators =
  cons_imp_to_HOL_state_def
  n_hashes_acc_imp_to_HOL_state_def

lemmas n_hashes_acc_complete_simps =
  n_hashes_acc_IMP_subprogram_simps
  n_hashes_acc_imp_subprogram_simps
  n_hashes_acc_state_translators

lemma n_hashes_acc_IMP_Minus_correct_function:
  "(invoke_subprogram p n_hashes_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p n_hashes_acc_ret_str)
      = n_hashes_acc_ret (n_hashes_acc_imp (n_hashes_acc_imp_to_HOL_state p s))"
  apply(induction "n_hashes_acc_imp_to_HOL_state p s" arbitrary: s s' t
      rule: n_hashes_acc_imp.induct)
  apply(subst n_hashes_acc_imp.simps)
  apply(simp only: n_hashes_acc_IMP_Minus_def prefix_simps)
  apply(erule Seq_E)+
  apply(erule While_tE)

  subgoal by (clarsimp simp: n_hashes_acc_complete_simps)

  apply(erule Seq_E)+
  apply(dest_com_gen)

  subgoal
    apply(simp only: n_hashes_acc_IMP_init_while_cond_def
        n_hashes_acc_IMP_loop_body_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_simps)

  subgoal
    apply(subst (asm) n_hashes_acc_IMP_init_while_cond_def)
    apply(simp only: prefix_simps n_hashes_acc_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_simps)

  subgoal
    apply(simp only: n_hashes_acc_IMP_init_while_cond_def prefix_simps
        n_hashes_acc_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_simps)
  done

lemma n_hashes_acc_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ n_hashes_acc_pref) n_hashes_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix n_hashes_acc_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma n_hashes_acc_IMP_Minus_correct_time_loop_condition:
  "(invoke_subprogram p n_hashes_acc_IMP_init_while_cond, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = n_hashes_acc_imp_compute_loop_condition_time 0 (n_hashes_acc_imp_to_HOL_state p s)"
  by (subst n_hashes_acc_imp_compute_loop_condition_time_def)
    (auto simp: n_hashes_acc_IMP_init_while_cond_def)

lemmas n_hashes_acc_complete_time_simps =
  n_hashes_acc_imp_subprogram_time_simps
  n_hashes_acc_imp_time_acc_2
  n_hashes_acc_imp_time_acc_3
  n_hashes_acc_state_translators

lemma n_hashes_acc_IMP_Minus_correct_time:
  "(invoke_subprogram p n_hashes_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = n_hashes_acc_imp_time 0 (n_hashes_acc_imp_to_HOL_state p s)"
  apply(induction "n_hashes_acc_imp_to_HOL_state p s" arbitrary: s s' t
      rule: n_hashes_acc_imp.induct)
  apply(subst n_hashes_acc_imp_time.simps)
  apply(simp only: n_hashes_acc_IMP_Minus_def prefix_simps)
  apply(erule Seq_tE)+
  apply(erule While_tE_time)
  subgoal
    by (fastforce simp: n_hashes_acc_IMP_subprogram_simps n_hashes_acc_imp_subprogram_time_simps
        n_hashes_acc_state_translators)

  apply(erule Seq_tE)+
  apply(clarsimp simp: add.assoc)
  apply(dest_com_gen_time)

  subgoal
    apply(simp only: n_hashes_acc_IMP_init_while_cond_def
        n_hashes_acc_IMP_loop_body_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_time_simps)

  subgoal
    apply(subst (asm) n_hashes_acc_IMP_init_while_cond_def)
    apply(simp only: prefix_simps n_hashes_acc_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_time_simps)

  subgoal
    apply(simp only: n_hashes_acc_IMP_init_while_cond_def prefix_simps
        n_hashes_acc_IMP_loop_body_def)
    apply(erule Seq_tE)+
    apply(erule cons_IMP_Minus_correct[where vars = "n_hashes_acc_IMP_vars"], fastforce)
    by (fastforce_sorted_premises simp: n_hashes_acc_complete_time_simps)
  done

lemma n_hashes_acc_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) n_hashes_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (n_hashes_acc_imp_time 0 (n_hashes_acc_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) n_hashes_acc_ret_str) =
        n_hashes_acc_ret (n_hashes_acc_imp (n_hashes_acc_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using n_hashes_acc_IMP_Minus_correct_function
  by (auto simp: n_hashes_acc_IMP_Minus_correct_time)
    (meson n_hashes_acc_IMP_Minus_correct_effects set_mono_prefix)


subsubsection \<open>n_hashes_tail\<close>

record n_hashes_tail_state =
  n_hashes_tail_n::nat
  n_hashes_tail_ret::nat

abbreviation "n_hashes_tail_prefix \<equiv> ''n_hashes_tail.''"
abbreviation "n_hashes_tail_n_str \<equiv> ''n''"
abbreviation "n_hashes_tail_ret_str \<equiv> ''ret''"

definition "n_hashes_tail_state_upd s =
  (let
      n_hashes_acc_acc' = 0;
      n_hashes_acc_n' = n_hashes_tail_n s;
      n_hashes_acc_ret' = 0;
      n_hashes_acc_state = \<lparr>n_hashes_acc_acc = n_hashes_acc_acc',
                            n_hashes_acc_n = n_hashes_acc_n',
                            n_hashes_acc_ret = n_hashes_acc_ret'\<rparr>;
      n_hashes_acc_ret_state = n_hashes_acc_imp n_hashes_acc_state;
      reverse_nat_n' = n_hashes_acc_ret n_hashes_acc_ret_state;
      reverse_nat_ret' = 0;
      reverse_nat_state = \<lparr>reverse_nat_n = reverse_nat_n',
                             reverse_nat_ret = reverse_nat_ret'\<rparr>;
      reverse_nat_ret_state = reverse_nat_imp reverse_nat_state;
      n_hashes_tail_ret' = reverse_nat_ret reverse_nat_ret_state;
      n_hashes_tail_n' = n_hashes_tail_n s;
      ret = \<lparr>n_hashes_tail_n = n_hashes_tail_n',
             n_hashes_tail_ret = n_hashes_tail_ret'\<rparr>
    in
      ret
  )"

function n_hashes_tail_imp:: "n_hashes_tail_state \<Rightarrow> n_hashes_tail_state" where
  "n_hashes_tail_imp s =
  (let
      ret = n_hashes_tail_state_upd s
    in
      ret
  )"
  by simp+
termination
  by (relation "measure (\<lambda>s. n_hashes_tail_n s)") simp

declare n_hashes_tail_imp.simps [simp del]

lemma n_hashes_tail_imp_correct:
  "n_hashes_tail_ret (n_hashes_tail_imp s) = n_hashes_tail (n_hashes_tail_n s)"
  by (simp add: n_hashes_acc_imp_correct n_hashes_tail_def n_hashes_tail_imp.simps
      n_hashes_tail_state_upd_def reverse_nat_imp_correct)

function n_hashes_tail_imp_time:: "nat \<Rightarrow> n_hashes_tail_state \<Rightarrow> nat" where
  "n_hashes_tail_imp_time t s =
  (let
      n_hashes_acc_acc' = 0;
      t = t + 2;
      n_hashes_acc_n' = n_hashes_tail_n s;
      t = t + 2;
      n_hashes_acc_ret' = 0;
      t = t + 2;
      n_hashes_acc_state = \<lparr>n_hashes_acc_acc = n_hashes_acc_acc',
                            n_hashes_acc_n = n_hashes_acc_n',
                            n_hashes_acc_ret = n_hashes_acc_ret'\<rparr>;
      n_hashes_acc_ret_state = n_hashes_acc_imp n_hashes_acc_state;
      t = t + n_hashes_acc_imp_time 0 n_hashes_acc_state;
      reverse_nat_n' = n_hashes_acc_ret n_hashes_acc_ret_state;
      t = t + 2;
      reverse_nat_ret' = 0;
      t = t + 2;
      reverse_nat_state = \<lparr>reverse_nat_n = reverse_nat_n',
                             reverse_nat_ret = reverse_nat_ret'\<rparr>;
      reverse_nat_ret_state = reverse_nat_imp reverse_nat_state;
      t = t + reverse_nat_imp_time 0 reverse_nat_state;
      n_hashes_tail_ret' = reverse_nat_ret reverse_nat_ret_state;
      t = t + 2;
      ret = t
    in
      ret
  )"
  by auto
termination
  by (relation "measure (\<lambda>(t, s). n_hashes_tail_n s)") simp

lemmas [simp del] = n_hashes_tail_imp_time.simps

lemma n_hashes_tail_imp_time_acc:
  "(n_hashes_tail_imp_time (Suc t) s) = Suc (n_hashes_tail_imp_time t s)"
  by (simp add: n_hashes_tail_imp_time.simps Let_def)

lemma n_hashes_tail_imp_time_acc_2:
  "(n_hashes_tail_imp_time x s) = x + (n_hashes_tail_imp_time 0 s)"
  by (simp add: n_hashes_tail_imp_time.simps Let_def)

definition n_hashes_tail_IMP_Minus where
  "n_hashes_tail_IMP_Minus \<equiv>
    \<comment> \<open>n_hashes_acc_acc' = 0;\<close>
    (n_hashes_acc_prefix @ n_hashes_acc_acc_str) ::= (A (N 0));;
    \<comment> \<open>n_hashes_acc_n' = n_hashes_tail_n s;\<close>
    (n_hashes_acc_prefix @ n_hashes_acc_n_str) ::= (A (V n_hashes_tail_n_str));;
    \<comment> \<open>n_hashes_acc_ret' = 0;\<close>
    (n_hashes_acc_prefix @ n_hashes_acc_ret_str) ::= (A (N 0));;
    \<comment> \<open>n_hashes_acc_state = \<lparr>n_hashes_acc_acc = n_hashes_acc_acc',\<close>
    \<comment> \<open>                      n_hashes_acc_n = n_hashes_acc_n',\<close>
    \<comment> \<open>                      n_hashes_acc_ret = n_hashes_acc_ret'\<rparr>;\<close>
    \<comment> \<open>n_hashes_acc_ret_state = n_hashes_acc_imp n_hashes_acc_state;\<close>
    invoke_subprogram n_hashes_acc_prefix n_hashes_acc_IMP_Minus;;
    \<comment> \<open>reverse_nat_n' = n_hashes_acc_ret n_hashes_acc_ret_state;\<close>
    (reverse_nat_prefix @ reverse_nat_n_str)
      ::= (A (V (n_hashes_acc_prefix @ n_hashes_acc_ret_str)));;
    \<comment> \<open>reverse_nat_ret' = 0;\<close>
    (reverse_nat_prefix @ reverse_nat_ret_str) ::= (A (N 0));;
    \<comment> \<open>reverse_nat_state = \<lparr>reverse_nat_n = reverse_nat_n',\<close>
    \<comment> \<open>                       reverse_nat_ret = reverse_nat_ret'\<rparr>;\<close>
    \<comment> \<open>reverse_nat_ret_state = reverse_nat_imp reverse_nat_state;\<close>
    invoke_subprogram reverse_nat_prefix reverse_nat_IMP_Minus;;
    \<comment> \<open>n_hashes_tail_ret' = reverse_nat_ret reverse_nat_ret_state;\<close>
    n_hashes_tail_ret_str ::= (A (V (reverse_nat_prefix @ reverse_nat_ret_str)))
"

abbreviation
  "n_hashes_tail_IMP_vars \<equiv>
  {n_hashes_tail_n_str, n_hashes_tail_ret_str}"

definition "n_hashes_tail_imp_to_HOL_state p s =
  \<lparr>n_hashes_tail_n = (s (add_prefix p n_hashes_tail_n_str)),
   n_hashes_tail_ret = (s (add_prefix p n_hashes_tail_ret_str))\<rparr>"

lemmas n_hashes_tail_state_translators =
  n_hashes_acc_imp_to_HOL_state_def
  reverse_nat_imp_to_HOL_state_def
  n_hashes_tail_imp_to_HOL_state_def

lemma n_hashes_tail_IMP_Minus_correct_function:
  "(invoke_subprogram p n_hashes_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p n_hashes_tail_ret_str)
      = n_hashes_tail_ret (n_hashes_tail_imp (n_hashes_tail_imp_to_HOL_state p s))"
  by (fastforce elim: reverse_nat_IMP_Minus_correct n_hashes_acc_IMP_Minus_correct
      simp: n_hashes_tail_state_translators n_hashes_tail_state_upd_def
      n_hashes_tail_IMP_Minus_def invoke_subprogram_append n_hashes_tail_imp.simps)

lemma n_hashes_tail_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ n_hashes_tail_pref) n_hashes_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix n_hashes_tail_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma n_hashes_tail_IMP_Minus_correct_time:
  "(invoke_subprogram p n_hashes_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = n_hashes_tail_imp_time 0 (n_hashes_tail_imp_to_HOL_state p s)"
  by (fastforce elim: n_hashes_acc_IMP_Minus_correct reverse_nat_IMP_Minus_correct
      simp: n_hashes_tail_imp_time.simps n_hashes_tail_imp_time_acc n_hashes_tail_imp_time_acc_2
      n_hashes_tail_state_translators Let_def n_hashes_tail_IMP_Minus_def invoke_subprogram_append)

lemma n_hashes_tail_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) n_hashes_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (n_hashes_tail_imp_time 0 (n_hashes_tail_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) n_hashes_tail_ret_str) =
        n_hashes_tail_ret (n_hashes_tail_imp (n_hashes_tail_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using n_hashes_tail_IMP_Minus_correct_time n_hashes_tail_IMP_Minus_correct_function
    n_hashes_tail_IMP_Minus_correct_effects
  by (meson set_mono_prefix)


subsection \<open>var_bit_to_var_nat\<close>

record var_bit_to_var_nat_state =
  var_bit_to_var_nat_n::nat
  var_bit_to_var_nat_ret::nat

abbreviation "var_bit_to_var_nat_prefix \<equiv> ''var_bit_to_var_nat.''"
abbreviation "var_bit_to_var_nat_n_str \<equiv> ''n''"
abbreviation "var_bit_to_var_nat_ret_str \<equiv> ''ret''"

definition "var_bit_to_var_nat_state_upd s =
  (let
      snd'_state_p' = var_bit_to_var_nat_n s;
      snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
      snd'_ret_state = snd'_imp snd'_state;
      n_hashes_tail_n' = snd'_state_p snd'_ret_state + 1;
      n_hashes_tail_ret' = 0;
      n_hashes_tail_state = \<lparr>n_hashes_tail_n = n_hashes_tail_n',
                             n_hashes_tail_ret = n_hashes_tail_ret'\<rparr>;
      n_hashes_tail_ret_state = n_hashes_tail_imp n_hashes_tail_state;
      append_nat_xs' = n_hashes_tail_ret n_hashes_tail_ret_state;
      append_nat_ys' = dollar_as_nat;
      append_nat_ret' = 0;
      append_nat_state = \<lparr>append_nat_xs = append_nat_xs',
                          append_nat_ys = append_nat_ys',
                          append_nat_ret = append_nat_ret'\<rparr>;
      append_nat_ret_state = append_nat_imp append_nat_state;
      fst'_state_p' = var_bit_to_var_nat_n s;
      fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
      fst'_ret_state = fst'_imp fst'_state;
      append_nat_xs' = append_nat_ret append_nat_ret_state;
      append_nat_ys' = fst'_state_p fst'_ret_state;
      append_nat_ret' = 0;
      append_nat_state = \<lparr>append_nat_xs = append_nat_xs',
                          append_nat_ys = append_nat_ys',
                          append_nat_ret = append_nat_ret'\<rparr>;
      append_nat_ret_state = append_nat_imp append_nat_state;
      var_bit_to_var_nat_n' = var_bit_to_var_nat_n s;
      var_bit_to_var_nat_ret' = append_nat_ret append_nat_ret_state;
      ret = \<lparr>var_bit_to_var_nat_n = var_bit_to_var_nat_n',
             var_bit_to_var_nat_ret = var_bit_to_var_nat_ret'\<rparr>
    in
      ret
  )"

function var_bit_to_var_nat_imp:: "var_bit_to_var_nat_state \<Rightarrow> var_bit_to_var_nat_state" where
  "var_bit_to_var_nat_imp s =
  (let
      ret = var_bit_to_var_nat_state_upd s
    in
      ret
  )"
  by simp+
termination
  by (relation "measure var_bit_to_var_nat_n") simp

declare var_bit_to_var_nat_imp.simps [simp del]

lemma var_bit_to_var_nat_imp_correct:
  "var_bit_to_var_nat_ret (var_bit_to_var_nat_imp s) = var_bit_to_var_nat (var_bit_to_var_nat_n s)"
  by (simp add: n_hashes_tail_imp_correct var_bit_to_var_nat_def var_bit_to_var_nat_imp.simps
      fst_nat_fst'_nat snd_nat_snd'_nat var_bit_to_var_nat_state_upd_def subtail_n_hashes
      snd'_imp_correct fst'_imp_correct append_nat_imp_correct dollar_encode_val)

function var_bit_to_var_nat_imp_time:: "nat \<Rightarrow> var_bit_to_var_nat_state \<Rightarrow> nat" where
  "var_bit_to_var_nat_imp_time t s =
  (let
      snd'_state_p' = var_bit_to_var_nat_n s;
      t = t + 2;
      snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
      snd'_ret_state = snd'_imp snd'_state;
      t = t + snd'_imp_time 0 snd'_state;
      n_hashes_tail_n' = snd'_state_p snd'_ret_state + 1;
      t = t + 2;
      n_hashes_tail_ret' = 0;
      t = t + 2;
      n_hashes_tail_state = \<lparr>n_hashes_tail_n = n_hashes_tail_n',
                             n_hashes_tail_ret = n_hashes_tail_ret'\<rparr>;
      n_hashes_tail_ret_state = n_hashes_tail_imp n_hashes_tail_state;
      t = t + n_hashes_tail_imp_time 0 n_hashes_tail_state;
      append_nat_xs' = n_hashes_tail_ret n_hashes_tail_ret_state;
      t = t + 2;
      append_nat_ys' = dollar_as_nat;
      t = t + 2;
      append_nat_ret' = 0;
      t = t + 2;
      append_nat_state = \<lparr>append_nat_xs = append_nat_xs',
                          append_nat_ys = append_nat_ys',
                          append_nat_ret = append_nat_ret'\<rparr>;
      append_nat_ret_state = append_nat_imp append_nat_state;
      t = t + append_nat_imp_time 0 append_nat_state;
      fst'_state_p' = var_bit_to_var_nat_n s;
      t = t + 2;
      fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
      fst'_ret_state = fst'_imp fst'_state;
      t = t + fst'_imp_time 0 fst'_state;
      append_nat_xs' = append_nat_ret append_nat_ret_state;
      t = t + 2;
      append_nat_ys' = fst'_state_p fst'_ret_state;
      t = t + 2;
      append_nat_ret' = 0;
      t = t + 2;
      append_nat_state = \<lparr>append_nat_xs = append_nat_xs',
                          append_nat_ys = append_nat_ys',
                          append_nat_ret = append_nat_ret'\<rparr>;
      append_nat_ret_state = append_nat_imp append_nat_state;
      t = t + append_nat_imp_time 0 append_nat_state;
      var_bit_to_var_nat_n' = var_bit_to_var_nat_n s;
      t = t + 2;
      var_bit_to_var_nat_ret' = append_nat_ret append_nat_ret_state;
      t = t + 2;
      ret = t
    in
      ret
  )"
  by auto
termination
  by (relation "measure (var_bit_to_var_nat_n \<circ> snd)") simp

lemmas [simp del] = var_bit_to_var_nat_imp_time.simps

lemma var_bit_to_var_nat_imp_time_acc:
  "(var_bit_to_var_nat_imp_time (Suc t) s) = Suc (var_bit_to_var_nat_imp_time t s)"
  by (simp add: var_bit_to_var_nat_imp_time.simps Let_def)

lemma var_bit_to_var_nat_imp_time_acc_2:
  "(var_bit_to_var_nat_imp_time x s) = x + (var_bit_to_var_nat_imp_time 0 s)"
  by (simp add: var_bit_to_var_nat_imp_time.simps Let_def)

definition var_bit_to_var_nat_IMP_Minus where
  "var_bit_to_var_nat_IMP_Minus \<equiv>
  \<comment> \<open>snd'_state_p' = var_bit_to_var_nat_n s;\<close>
  (snd'_prefix @ snd'_p_str) ::= (A (V var_bit_to_var_nat_n_str));;
  \<comment> \<open>snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;\<close>
  \<comment> \<open>snd'_ret_state = snd'_imp snd'_state;\<close>
  invoke_subprogram snd'_prefix snd'_IMP_Minus;;
  \<comment> \<open>n_hashes_tail_n' = snd'_state_p snd'_ret_state + 1;\<close>
  (n_hashes_tail_prefix @ n_hashes_tail_n_str) ::= (Plus (V (snd'_prefix @ snd'_p_str)) (N 1));;
  \<comment> \<open>n_hashes_tail_ret' = 0;\<close>
  (n_hashes_tail_prefix @ n_hashes_tail_ret_str) ::= (A (N 0));;
  \<comment> \<open>n_hashes_tail_state = \<lparr>n_hashes_tail_n = n_hashes_tail_n',\<close>
  \<comment> \<open>                       n_hashes_tail_ret = n_hashes_tail_ret'\<rparr>;\<close>
  \<comment> \<open>n_hashes_tail_ret_state = n_hashes_tail_imp n_hashes_tail_state;\<close>
  invoke_subprogram n_hashes_tail_prefix n_hashes_tail_IMP_Minus;;
  \<comment> \<open>append_nat_xs' = n_hashes_tail_ret n_hashes_tail_ret_state;\<close>
  (append_nat_prefix @ append_nat_xs_str)
    ::= (A (V (n_hashes_tail_prefix @ n_hashes_tail_ret_str)));;
  \<comment> \<open>append_nat_ys' = dollar_as_nat;\<close>
  (append_nat_prefix @ append_nat_ys_str) ::= (A (N dollar_as_nat));;
  \<comment> \<open>append_nat_ret' = 0;\<close>
  (append_nat_prefix @ append_nat_ret_str) ::= (A (N 0));;
  \<comment> \<open>append_nat_state = \<lparr>append_nat_xs = append_nat_xs',\<close>
  \<comment> \<open>                    append_nat_ys = append_nat_ys',\<close>
  \<comment> \<open>                    append_nat_ret = append_nat_ret'\<rparr>;\<close>
  \<comment> \<open>append_nat_ret_state = append_nat_imp append_nat_state;\<close>
  invoke_subprogram append_nat_prefix append_nat_IMP_Minus;;
  \<comment> \<open>fst'_state_p' = var_bit_to_var_nat_n s;\<close>
  (fst'_prefix @ fst'_p_str) ::= (A (V var_bit_to_var_nat_n_str));;
  \<comment> \<open>fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;\<close>
  \<comment> \<open>fst'_ret_state = fst'_imp fst'_state;\<close>
  invoke_subprogram fst'_prefix fst'_IMP_Minus;;
  \<comment> \<open>append_nat_xs' = append_nat_ret append_nat_ret_state;\<close>
  (append_nat_prefix @ append_nat_xs_str) ::= (A (V (append_nat_prefix @ append_nat_ret_str)));;
  \<comment> \<open>append_nat_ys' = fst'_state_p fst'_ret_state;\<close>
  (append_nat_prefix @ append_nat_ys_str) ::= (A (V (fst'_prefix @ fst'_p_str)));;
  \<comment> \<open>append_nat_ret' = 0;\<close>
  (append_nat_prefix @ append_nat_ret_str) ::= (A (N 0));;
  \<comment> \<open>append_nat_state = \<lparr>append_nat_xs = append_nat_xs',\<close>
  \<comment> \<open>                    append_nat_ys = append_nat_ys',\<close>
  \<comment> \<open>                    append_nat_ret = append_nat_ret'\<rparr>;\<close>
  \<comment> \<open>append_nat_ret_state = append_nat_imp append_nat_state;\<close>
  invoke_subprogram append_nat_prefix append_nat_IMP_Minus;;
  \<comment> \<open>var_bit_to_var_nat_n' = var_bit_to_var_nat_n s;\<close>
  var_bit_to_var_nat_n_str ::= (A (V var_bit_to_var_nat_n_str));;
  \<comment> \<open>var_bit_to_var_nat_ret' = append_nat_ret append_nat_ret_state;\<close>
  var_bit_to_var_nat_ret_str ::= (A (V (append_nat_prefix @ append_nat_ret_str)))
"

abbreviation
  "var_bit_to_var_nat_IMP_vars \<equiv>
  {var_bit_to_var_nat_n_str, var_bit_to_var_nat_ret_str}"

definition "var_bit_to_var_nat_imp_to_HOL_state p s =
  \<lparr>var_bit_to_var_nat_n = (s (add_prefix p var_bit_to_var_nat_n_str)),
   var_bit_to_var_nat_ret = (s (add_prefix p var_bit_to_var_nat_ret_str))\<rparr>"

lemmas var_bit_to_var_nat_state_translators =
  fst'_imp_to_HOL_state_def
  snd'_imp_to_HOL_state_def
  n_hashes_tail_imp_to_HOL_state_def
  append_nat_imp_to_HOL_state_def
  var_bit_to_var_nat_imp_to_HOL_state_def

lemma var_bit_to_var_nat_IMP_Minus_correct_function:
  "(invoke_subprogram p var_bit_to_var_nat_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p var_bit_to_var_nat_ret_str)
      = var_bit_to_var_nat_ret (var_bit_to_var_nat_imp (var_bit_to_var_nat_imp_to_HOL_state p s))"
  apply (subst var_bit_to_var_nat_imp.simps)
  apply (simp only: var_bit_to_var_nat_IMP_Minus_def prefix_simps)
  apply (erule Seq_E)+

  apply (erule snd'_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(17) by fastforce
  apply (erule n_hashes_tail_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(19) by fastforce
  apply (erule append_nat_IMP_Minus_correct[where vars = "var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(21) by fastforce
  apply (erule fst'_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(23) by fastforce
  apply (erule append_nat_IMP_Minus_correct[where vars = "var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(25) by fastforce

  by (fastforce simp: var_bit_to_var_nat_state_translators var_bit_to_var_nat_state_upd_def)

lemma var_bit_to_var_nat_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ var_bit_to_var_nat_pref) var_bit_to_var_nat_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix var_bit_to_var_nat_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma var_bit_to_var_nat_IMP_Minus_correct_time:
  "(invoke_subprogram p var_bit_to_var_nat_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = var_bit_to_var_nat_imp_time 0 (var_bit_to_var_nat_imp_to_HOL_state p s)"
  apply (subst var_bit_to_var_nat_imp_time.simps)
  apply (simp only: var_bit_to_var_nat_IMP_Minus_def prefix_simps)
  apply (erule Seq_tE)+

  apply (erule snd'_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(33) by fastforce
  apply (erule n_hashes_tail_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(35) by fastforce
  apply (erule append_nat_IMP_Minus_correct[where vars = "var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(37) by fastforce
  apply (erule fst'_IMP_Minus_correct[where
        vars = "insert (append_nat_prefix @ append_nat_ret_str) var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(39) by fastforce
  apply (erule append_nat_IMP_Minus_correct[where vars = "var_bit_to_var_nat_IMP_vars"])
  subgoal premises p using p(41) by fastforce

  by (fastforce simp add: Let_def var_bit_to_var_nat_state_translators)

lemma var_bit_to_var_nat_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) var_bit_to_var_nat_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (var_bit_to_var_nat_imp_time 0 (var_bit_to_var_nat_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) var_bit_to_var_nat_ret_str) =
        var_bit_to_var_nat_ret
          (var_bit_to_var_nat_imp (var_bit_to_var_nat_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using var_bit_to_var_nat_IMP_Minus_correct_time var_bit_to_var_nat_IMP_Minus_correct_function
    var_bit_to_var_nat_IMP_Minus_correct_effects
  by (meson set_mono_prefix)


subsection \<open>operand_bit_to_var\<close>

subsubsection \<open>operand_bit_to_var_acc\<close>

fun operand_bit_to_var_acc':: "nat \<Rightarrow> nat \<Rightarrow> nat" where
  "operand_bit_to_var_acc' acc p  =
  (if snd_nat p \<noteq> 0
   then (operand_bit_to_var_acc' ((fst_nat p) ## acc) (prod_encode (fst_nat p, snd_nat p - 1)))
   else acc
  )"

lemma operand_bit_to_var_acc'_correct:
  "operand_bit_to_var_acc' acc n = operand_bit_to_var_acc acc n"
  by (induction acc n rule : operand_bit_to_var_acc.induct) simp

record operand_bit_to_var_acc_state =
  operand_bit_to_var_acc_acc::nat
  operand_bit_to_var_acc_n::nat
  operand_bit_to_var_acc_ret::nat

abbreviation "operand_bit_to_var_acc_prefix \<equiv> ''operand_bit_to_var_acc.''"
abbreviation "operand_bit_to_var_acc_acc_str \<equiv> ''acc''"
abbreviation "operand_bit_to_var_acc_n_str \<equiv> ''n''"
abbreviation "operand_bit_to_var_acc_ret_str \<equiv> ''ret''"

definition "operand_bit_to_var_acc_state_upd s \<equiv>
  let
    fst'_state_p' = operand_bit_to_var_acc_n s;
    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
    fst'_ret_state = fst'_imp fst'_state;
    fst'_result = fst'_state_p fst'_ret_state;
    snd'_state_p' = operand_bit_to_var_acc_n s;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    snd'_result = snd'_state_p snd'_ret_state;
    prod_encode_a' = fst'_result;
    prod_encode_b' = snd'_result - 1;
    prod_encode_ret' = 0;
    prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
                         prod_encode_b = prod_encode_b',
                         prod_encode_ret = prod_encode_ret'\<rparr>;
    prod_encode_ret_state = prod_encode_imp prod_encode_state;
    prod_result = prod_encode_ret prod_encode_ret_state;
    cons_h' = fst'_result;
    cons_t' = operand_bit_to_var_acc_acc s;
    cons_ret' = 0;
    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
    cons_ret_state = cons_imp cons_state;
    cons_result = cons_ret cons_ret_state;
    operand_bit_to_var_acc_acc' = cons_result;
    operand_bit_to_var_acc_n' = prod_result;
    operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_ret s;
    ret = \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',
           operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',
           operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>
  in
    ret
"

definition "operand_bit_to_var_acc_imp_compute_loop_condition s \<equiv>
  let
    snd'_state_p' = operand_bit_to_var_acc_n s;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    condition = snd'_state_p snd'_ret_state
  in condition
"

definition "operand_bit_to_var_acc_imp_after_loop s \<equiv>
  let
    operand_bit_to_var_acc_acc' = operand_bit_to_var_acc_acc s;
    operand_bit_to_var_acc_n' = operand_bit_to_var_acc_n s;
    operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_acc s;
    ret = \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',
           operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',
           operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>
  in ret
"

lemmas operand_bit_to_var_acc_imp_subprogram_simps =
  operand_bit_to_var_acc_imp_after_loop_def
  operand_bit_to_var_acc_state_upd_def
  operand_bit_to_var_acc_imp_compute_loop_condition_def

function operand_bit_to_var_acc_imp::
  "operand_bit_to_var_acc_state \<Rightarrow> operand_bit_to_var_acc_state" where
  "operand_bit_to_var_acc_imp s =
  (if operand_bit_to_var_acc_imp_compute_loop_condition s \<noteq> 0
   then
    (let next_iteration = operand_bit_to_var_acc_imp (operand_bit_to_var_acc_state_upd s)
      in next_iteration)
  else
    (let ret = operand_bit_to_var_acc_imp_after_loop s in ret)
  )"
  by simp+
termination
  apply (relation "measure operand_bit_to_var_acc_n")
   apply (simp add: operand_bit_to_var_acc_imp_subprogram_simps Let_def snd'_imp_correct
      fst'_imp_correct prod_encode_imp_correct fst'_nat_def snd'_nat_def prod_encode_def
      nat_less_le triangle_tsqrt_le triangle_nat_le_eq_le le_diff_conv)+
  by (metis add_cancel_right_left add_diff_cancel_left' diff_diff_cancel diff_is_0_eq less_Suc0
      nat_le_linear not_gr_zero triangle_tsqrt_le tsqrt_alt_inverse_triangle)

declare operand_bit_to_var_acc_imp.simps [simp del]

lemma operand_bit_to_var_acc_imp_correct:
  "operand_bit_to_var_acc_ret (operand_bit_to_var_acc_imp s) =
    operand_bit_to_var_acc' (operand_bit_to_var_acc_acc s) (operand_bit_to_var_acc_n s)"
  apply (induction s rule: operand_bit_to_var_acc_imp.induct)
  apply (subst operand_bit_to_var_acc_imp.simps)
  apply (subst operand_bit_to_var_acc'.simps)
  by (simp del: operand_bit_to_var_acc'.simps add: operand_bit_to_var_acc_imp_subprogram_simps
      snd'_imp_correct fst'_imp_correct prod_encode_imp_correct cons_imp_correct fst_nat_fst'_nat
      snd_nat_snd'_nat Let_def)

definition "operand_bit_to_var_acc_state_upd_time t s \<equiv>
  let
    fst'_state_p' = operand_bit_to_var_acc_n s;
    t = t + 2;
    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
    fst'_ret_state = fst'_imp fst'_state;
    t = t + fst'_imp_time 0 fst'_state;
    fst'_result = fst'_state_p fst'_ret_state;
    t = t + 2;
    snd'_state_p' = operand_bit_to_var_acc_n s;
    t = t + 2;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    t = t + snd'_imp_time 0 snd'_state;
    snd'_result = snd'_state_p snd'_ret_state;
    t = t + 2;
    prod_encode_a' = fst'_result;
    t = t + 2;
    prod_encode_b' = snd'_result - 1;
    t = t + 2;
    prod_encode_ret' = 0;
    t = t + 2;
    prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
                         prod_encode_b = prod_encode_b',
                         prod_encode_ret = prod_encode_ret'\<rparr>;
    prod_encode_ret_state = prod_encode_imp prod_encode_state;
    t = t + prod_encode_imp_time 0 prod_encode_state;
    prod_result = prod_encode_ret prod_encode_ret_state;
    t = t + 2;
    cons_h' = fst'_result;
    t = t + 2;
    cons_t' = operand_bit_to_var_acc_acc s;
    t = t + 2;
    cons_ret' = 0;
    t = t + 2;
    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
    cons_ret_state = cons_imp cons_state;
    t = t + cons_imp_time 0 cons_state;
    cons_result = cons_ret cons_ret_state;
    t = t + 2;
    operand_bit_to_var_acc_acc' = cons_result;
    t = t + 2;
    operand_bit_to_var_acc_n' = prod_result;
    t = t + 2;
    operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_ret s;
    t = t + 2;
    ret = t
  in
    ret
"

definition "operand_bit_to_var_acc_imp_compute_loop_condition_time t s \<equiv>
  (let
    snd'_state_p' = operand_bit_to_var_acc_n s;
    t = t + 2;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    t = t + snd'_imp_time 0 snd'_state;
    condition = snd'_state_p snd'_ret_state;
    t = t + 2;
    ret = t
   in ret
  )"

definition "operand_bit_to_var_acc_imp_after_loop_time t s \<equiv>
  (let
    operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_acc s;
    t = t + 2;
    ret = t
   in ret
  )"

lemmas operand_bit_to_var_acc_imp_subprogram_time_simps =
  operand_bit_to_var_acc_imp_subprogram_simps
  operand_bit_to_var_acc_imp_after_loop_time_def
  operand_bit_to_var_acc_state_upd_time_def
  operand_bit_to_var_acc_imp_compute_loop_condition_time_def

function operand_bit_to_var_acc_imp_time:: "nat \<Rightarrow> operand_bit_to_var_acc_state \<Rightarrow> nat" where
  "operand_bit_to_var_acc_imp_time t s =
  operand_bit_to_var_acc_imp_compute_loop_condition_time 0 s +
  (if operand_bit_to_var_acc_imp_compute_loop_condition s \<noteq> 0
   then
    (let
        t = t + 1;
        next_iteration
          = operand_bit_to_var_acc_imp_time (t + operand_bit_to_var_acc_state_upd_time 0 s)
                                            (operand_bit_to_var_acc_state_upd s)
     in next_iteration)
  else
    (let
        t = t + 2;
        ret = t + operand_bit_to_var_acc_imp_after_loop_time 0 s
     in ret)
  )"
  by auto
termination
  apply (relation "measure (operand_bit_to_var_acc_n \<circ> snd)")
   apply (simp add: operand_bit_to_var_acc_imp_subprogram_time_simps Let_def snd'_imp_correct
      fst'_imp_correct prod_encode_imp_correct fst'_nat_def snd'_nat_def prod_encode_def
      nat_less_le triangle_tsqrt_le triangle_nat_le_eq_le le_diff_conv)+
  by (metis add_cancel_right_left add_diff_cancel_left' diff_diff_cancel diff_is_0_eq less_Suc0
      nat_le_linear not_gr_zero triangle_tsqrt_le tsqrt_alt_inverse_triangle)

lemmas [simp del] = operand_bit_to_var_acc_imp_time.simps

lemma operand_bit_to_var_acc_imp_time_acc:
  "(operand_bit_to_var_acc_imp_time (Suc t) s) = Suc (operand_bit_to_var_acc_imp_time t s)"
  by (induction t s rule: operand_bit_to_var_acc_imp_time.induct)
    ((subst (1 2) operand_bit_to_var_acc_imp_time.simps);
      (simp add: operand_bit_to_var_acc_state_upd_def))

lemma operand_bit_to_var_acc_imp_time_acc_2_aux:
  "(operand_bit_to_var_acc_imp_time x s) = x + (operand_bit_to_var_acc_imp_time 0 s)"
  by (induction x arbitrary: s)
    (simp add: operand_bit_to_var_acc_imp_time_acc)+

lemma operand_bit_to_var_acc_imp_time_acc_2:
  "x \<noteq> 0 \<Longrightarrow> (operand_bit_to_var_acc_imp_time x s) = x + (operand_bit_to_var_acc_imp_time 0 s)"
  by (rule operand_bit_to_var_acc_imp_time_acc_2_aux)

lemma operand_bit_to_var_acc_imp_time_acc_3:
  "operand_bit_to_var_acc_imp_time (a + b) s = a + (operand_bit_to_var_acc_imp_time b s)"
  by (induction a arbitrary: b s) (simp add: operand_bit_to_var_acc_imp_time_acc)+

abbreviation "operand_bit_to_var_acc_while_cond \<equiv> ''condition''"
abbreviation "operand_bit_to_var_acc_fst'_result \<equiv> ''fst'_result''"
abbreviation "operand_bit_to_var_acc_snd'_result \<equiv> ''snd'_result''"
abbreviation "operand_bit_to_var_acc_prod_encode_result \<equiv> ''prod_encode_result''"
abbreviation "operand_bit_to_var_acc_cons_result \<equiv> ''cons_result''"

definition "operand_bit_to_var_acc_IMP_init_while_cond \<equiv>
  \<comment> \<open>    snd'_state_p' = operand_bit_to_var_acc_n s;\<close>
  (snd'_prefix @ snd'_p_str) ::= (A (V operand_bit_to_var_acc_n_str));;
  \<comment> \<open>    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;\<close>
  \<comment> \<open>    snd'_ret_state = snd'_imp snd'_state;\<close>
  invoke_subprogram snd'_prefix snd'_IMP_Minus;;
  \<comment> \<open>    condition = snd'_state_p snd'_ret_state\<close>
  operand_bit_to_var_acc_while_cond ::= (A (V (snd'_prefix @ snd'_p_str)))
"

definition "operand_bit_to_var_acc_IMP_loop_body \<equiv>
  \<comment> \<open>fst'_state_p' = operand_bit_to_var_acc_n s;\<close>
  (fst'_prefix @ fst'_p_str) ::= (A (V operand_bit_to_var_acc_n_str));;
  \<comment> \<open>fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;\<close>
  \<comment> \<open>fst'_ret_state = fst'_imp fst'_state;\<close>
  invoke_subprogram fst'_prefix fst'_IMP_Minus;;
  operand_bit_to_var_acc_fst'_result ::= (A (V (fst'_prefix @ fst'_p_str)));;
  \<comment> \<open>snd'_state_p' = operand_bit_to_var_acc_n s;\<close>
  (snd'_prefix @ snd'_p_str) ::= (A (V operand_bit_to_var_acc_n_str));;
  \<comment> \<open>snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;\<close>
  \<comment> \<open>snd'_ret_state = snd'_imp snd'_state;\<close>
  invoke_subprogram snd'_prefix snd'_IMP_Minus;;
  operand_bit_to_var_acc_snd'_result ::= (A (V (snd'_prefix @ snd'_p_str)));;
  \<comment> \<open>prod_encode_a' = fst'_state_p fst'_ret_state;\<close>
  (prod_encode_prefix @ prod_encode_a_str) ::= (A (V operand_bit_to_var_acc_fst'_result));;
  \<comment> \<open>prod_encode_b' = snd'_state_p snd'_ret_state - 1;\<close>
  (prod_encode_prefix @ prod_encode_b_str) ::= (Sub (V operand_bit_to_var_acc_snd'_result) (N 1));;
  \<comment> \<open>prod_encode_ret' = 0;\<close>
  (prod_encode_prefix @ prod_encode_ret_str) ::= (A (N 0));;
  \<comment> \<open>prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',\<close>
  \<comment> \<open>                     prod_encode_b = prod_encode_b',\<close>
  \<comment> \<open>                     prod_encode_ret = prod_encode_ret'\<rparr>;\<close>
  \<comment> \<open>prod_encode_ret_state = prod_encode_imp prod_encode_state;\<close>
  invoke_subprogram prod_encode_prefix prod_encode_IMP_Minus;;
  operand_bit_to_var_acc_prod_encode_result ::= (A (V (prod_encode_prefix @ prod_encode_ret_str)));;
  \<comment> \<open>cons_h' = fst'_state_p fst'_ret_state;\<close>
  (cons_prefix @ cons_h_str) ::= (A (V operand_bit_to_var_acc_fst'_result));;
  \<comment> \<open>cons_t' = operand_bit_to_var_acc_acc s;\<close>
  (cons_prefix @ cons_t_str) ::= (A (V operand_bit_to_var_acc_acc_str));;
  \<comment> \<open>cons_ret' = 0;\<close>
  (cons_prefix @ cons_ret_str) ::= (A (N 0));;
  \<comment> \<open>cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;\<close>
  \<comment> \<open>cons_ret_state = cons_imp cons_state;\<close>
  invoke_subprogram cons_prefix cons_IMP_Minus;;
  operand_bit_to_var_acc_cons_result ::= (A (V (cons_prefix @ cons_ret_str)));;
  \<comment> \<open>operand_bit_to_var_acc_acc' = cons_ret cons_ret_state;\<close>
  operand_bit_to_var_acc_acc_str ::= (A (V operand_bit_to_var_acc_cons_result));;
  \<comment> \<open>operand_bit_to_var_acc_n' = prod_encode_ret prod_encode_ret_state;\<close>
  operand_bit_to_var_acc_n_str ::= (A (V operand_bit_to_var_acc_prod_encode_result));;
  \<comment> \<open>operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_ret s;\<close>
  operand_bit_to_var_acc_ret_str ::= (A (V operand_bit_to_var_acc_ret_str))
  \<comment> \<open>ret = \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>\<close>
"

definition "operand_bit_to_var_acc_IMP_after_loop \<equiv>
  \<comment> \<open>operand_bit_to_var_acc_ret' = operand_bit_to_var_acc_acc s;\<close>
  operand_bit_to_var_acc_ret_str ::= (A (V operand_bit_to_var_acc_acc_str))
  \<comment> \<open>ret = \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>\<close>
"

definition operand_bit_to_var_acc_IMP_Minus where
  "operand_bit_to_var_acc_IMP_Minus \<equiv>
  operand_bit_to_var_acc_IMP_init_while_cond;;
  WHILE operand_bit_to_var_acc_while_cond \<noteq>0 DO (
    operand_bit_to_var_acc_IMP_loop_body;;
    operand_bit_to_var_acc_IMP_init_while_cond
  );;
  operand_bit_to_var_acc_IMP_after_loop"

abbreviation
  "operand_bit_to_var_acc_IMP_vars \<equiv>
  {operand_bit_to_var_acc_acc_str, operand_bit_to_var_acc_n_str, operand_bit_to_var_acc_ret_str,
   operand_bit_to_var_acc_fst'_result, operand_bit_to_var_acc_snd'_result,
   operand_bit_to_var_acc_prod_encode_result, operand_bit_to_var_acc_cons_result}"

lemmas operand_bit_to_var_acc_IMP_subprogram_simps =
  operand_bit_to_var_acc_IMP_init_while_cond_def
  operand_bit_to_var_acc_IMP_loop_body_def
  operand_bit_to_var_acc_IMP_after_loop_def

definition "operand_bit_to_var_acc_imp_to_HOL_state p s =
  \<lparr>operand_bit_to_var_acc_acc = (s (add_prefix p operand_bit_to_var_acc_acc_str)),
   operand_bit_to_var_acc_n = (s (add_prefix p operand_bit_to_var_acc_n_str)),
   operand_bit_to_var_acc_ret = (s (add_prefix p operand_bit_to_var_acc_ret_str))\<rparr>"

lemmas operand_bit_to_var_acc_state_translators =
  fst'_imp_to_HOL_state_def
  snd'_imp_to_HOL_state_def
  prod_encode_imp_to_HOL_state_def
  cons_imp_to_HOL_state_def
  operand_bit_to_var_acc_imp_to_HOL_state_def

lemmas operand_bit_to_var_acc_complete_simps =
  operand_bit_to_var_acc_IMP_subprogram_simps
  operand_bit_to_var_acc_imp_subprogram_simps
  operand_bit_to_var_acc_state_translators

lemma operand_bit_to_var_acc_IMP_Minus_correct_function:
  "(invoke_subprogram p operand_bit_to_var_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p operand_bit_to_var_acc_ret_str)
      = operand_bit_to_var_acc_ret
          (operand_bit_to_var_acc_imp (operand_bit_to_var_acc_imp_to_HOL_state p s))"
  apply(induction "operand_bit_to_var_acc_imp_to_HOL_state p s" arbitrary: s s' t
      rule: operand_bit_to_var_acc_imp.induct)
  apply(subst operand_bit_to_var_acc_imp.simps)
  apply(simp only: operand_bit_to_var_acc_IMP_Minus_def prefix_simps)
  apply(erule Seq_E)+
  apply(erule While_tE)

  subgoal
    apply(simp only: operand_bit_to_var_acc_IMP_subprogram_simps)
    apply(simp only: prefix_simps)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(8) by fastforce
    by(fastforce simp: operand_bit_to_var_acc_IMP_subprogram_simps
        operand_bit_to_var_acc_imp_subprogram_simps
        operand_bit_to_var_acc_state_translators)

  apply(erule Seq_E)+
  apply(dest_com_gen)

  subgoal
    apply(simp only: operand_bit_to_var_acc_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(10) by fastforce
    by(fastforce_sorted_premises simp: operand_bit_to_var_acc_complete_simps)

  subgoal
    apply(subst (asm) operand_bit_to_var_acc_IMP_init_while_cond_def)
    apply(simp only: operand_bit_to_var_acc_IMP_loop_body_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(26) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(28) by fastforce
    apply(erule fst'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(30) by fastforce
    apply(erule cons_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(32) by fastforce
    apply(erule prod_encode_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(34) by fastforce
    by (fastforce_sorted_premises simp: operand_bit_to_var_acc_imp_subprogram_simps
        operand_bit_to_var_acc_state_translators Let_def)

  subgoal
    apply(simp only: operand_bit_to_var_acc_IMP_init_while_cond_def prefix_simps
        operand_bit_to_var_acc_IMP_loop_body_def)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(28) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(30) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(32) by fastforce
    apply(erule fst'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(34) by fastforce
    apply(erule cons_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(36) by fastforce
    apply(erule prod_encode_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(38) by fastforce
    by (fastforce_sorted_premises simp: operand_bit_to_var_acc_imp_subprogram_simps
        operand_bit_to_var_acc_state_translators Let_def)
  done

lemma operand_bit_to_var_acc_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ operand_bit_to_var_acc_pref)
                       operand_bit_to_var_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix operand_bit_to_var_acc_pref v)\<rbrakk>
   \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemmas operand_bit_to_var_acc_complete_time_simps =
  operand_bit_to_var_acc_imp_subprogram_time_simps
  operand_bit_to_var_acc_imp_time_acc_2
  operand_bit_to_var_acc_imp_time_acc_3
  operand_bit_to_var_acc_state_translators

lemma operand_bit_to_var_acc_IMP_Minus_correct_time:
  "(invoke_subprogram p operand_bit_to_var_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = operand_bit_to_var_acc_imp_time 0 (operand_bit_to_var_acc_imp_to_HOL_state p s)"
  apply(induction "operand_bit_to_var_acc_imp_to_HOL_state p s" arbitrary: s s' t
      rule: operand_bit_to_var_acc_imp.induct)
  apply(subst operand_bit_to_var_acc_imp_time.simps)
  apply(simp only: operand_bit_to_var_acc_IMP_Minus_def prefix_simps)

  apply(erule Seq_tE)+
  apply(erule While_tE_time)

  subgoal
    apply(simp only: operand_bit_to_var_acc_IMP_subprogram_simps prefix_simps)
    apply(erule Seq_tE)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(12) by fastforce
    by (force simp: operand_bit_to_var_acc_IMP_subprogram_simps
        operand_bit_to_var_acc_imp_subprogram_time_simps operand_bit_to_var_acc_state_translators)

  apply(erule Seq_tE)+
  apply(simp add: add.assoc)
  apply(dest_com_gen_time)

  subgoal
    apply(simp only: operand_bit_to_var_acc_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(13) by fastforce
    by(fastforce_sorted_premises simp: operand_bit_to_var_acc_complete_simps)

  subgoal
    apply(subst (asm) operand_bit_to_var_acc_IMP_init_while_cond_def)
    apply(simp only: operand_bit_to_var_acc_IMP_loop_body_def prefix_simps)
    apply(erule Seq_E)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(29) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(31) by fastforce
    apply(erule fst'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(33) by fastforce
    apply(erule cons_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(35) by fastforce
    apply(erule prod_encode_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(37) by fastforce
    by(fastforce_sorted_premises simp: operand_bit_to_var_acc_complete_time_simps Let_def)

  subgoal
    apply(simp only: prefix_simps operand_bit_to_var_acc_IMP_init_while_cond_def
        operand_bit_to_var_acc_IMP_loop_body_def)
    apply(erule Seq_tE)+
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(53) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(55) by fastforce
    apply(erule snd'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(57) by fastforce
    apply(erule fst'_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(59) by fastforce
    apply(erule cons_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(61) by fastforce
    apply(erule prod_encode_IMP_Minus_correct[where vars = "operand_bit_to_var_acc_IMP_vars"])
    subgoal premises p using p(63) by fastforce
    by(fastforce_sorted_premises simp: Let_def operand_bit_to_var_acc_complete_time_simps)
  done

lemma operand_bit_to_var_acc_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) operand_bit_to_var_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
    \<lbrakk>t = (operand_bit_to_var_acc_imp_time 0 (operand_bit_to_var_acc_imp_to_HOL_state (p1 @ p2) s));
     s' (add_prefix (p1 @ p2) operand_bit_to_var_acc_ret_str) =
          operand_bit_to_var_acc_ret (operand_bit_to_var_acc_imp
                                        (operand_bit_to_var_acc_imp_to_HOL_state (p1 @ p2) s));
     \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
   \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using operand_bit_to_var_acc_IMP_Minus_correct_function
  by (auto simp: operand_bit_to_var_acc_IMP_Minus_correct_time)
    (meson operand_bit_to_var_acc_IMP_Minus_correct_effects set_mono_prefix)


subsubsection \<open>operand_bit_to_var_tail\<close>

record operand_bit_to_var_tail_state =
  operand_bit_to_var_tail_n::nat
  operand_bit_to_var_tail_ret::nat

abbreviation "operand_bit_to_var_tail_prefix \<equiv> ''operand_bit_to_var_tail.''"
abbreviation "operand_bit_to_var_tail_n_str \<equiv> ''n''"
abbreviation "operand_bit_to_var_tail_ret_str \<equiv> ''ret''"

definition "operand_bit_to_var_tail_state_upd s =
  (let
      fst'_state_p' = operand_bit_to_var_tail_n s;
      fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
      fst'_ret_state = fst'_imp fst'_state;
      fst'_result = fst'_state_p fst'_ret_state;
      cons_h' = fst'_result;
      cons_t' = 0;
      cons_ret' = 0;
      cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
      cons_ret_state = cons_imp cons_state;
      cons_result = cons_ret cons_ret_state;
      operand_bit_to_var_acc_acc' = cons_result;
      operand_bit_to_var_acc_n' = operand_bit_to_var_tail_n s;
      operand_bit_to_var_acc_ret' = 0;
      operand_bit_to_var_acc_state =
        \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',
         operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',
         operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>;
      operand_bit_to_var_acc_ret_state = operand_bit_to_var_acc_imp operand_bit_to_var_acc_state;
      operand_bit_to_var_acc_result = operand_bit_to_var_acc_ret operand_bit_to_var_acc_ret_state;
      operand_bit_to_var_tail_n' = operand_bit_to_var_tail_n s;
      operand_bit_to_var_tail_ret' = operand_bit_to_var_acc_result;
      ret = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n',
             operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>
    in
      ret
  )"

function operand_bit_to_var_tail_imp::
  "operand_bit_to_var_tail_state \<Rightarrow> operand_bit_to_var_tail_state" where
  "operand_bit_to_var_tail_imp s =
  (let
      ret = operand_bit_to_var_tail_state_upd s
    in
      ret
  )"
  by simp+
termination
  by (relation "measure (\<lambda>s. operand_bit_to_var_tail_n s)") simp

declare operand_bit_to_var_tail_imp.simps [simp del]

lemma operand_bit_to_var_tail_imp_correct:
  "operand_bit_to_var_tail_ret (operand_bit_to_var_tail_imp s) =
    operand_bit_to_var_tail (operand_bit_to_var_tail_n s)"
  by(simp add: operand_bit_to_var_tail_imp.simps operand_bit_to_var_tail_state_upd_def
      fst'_imp_correct cons_imp_correct)
    (simp only: operand_bit_to_var_tail_def operand_bit_to_var_acc_imp_correct
      operand_bit_to_var_acc'_correct operand_bit_to_var_acc_state.simps fst_nat_fst'_nat)

function operand_bit_to_var_tail_imp_time:: "nat \<Rightarrow> operand_bit_to_var_tail_state \<Rightarrow> nat" where
  "operand_bit_to_var_tail_imp_time t s =
    (let
      fst'_state_p' = operand_bit_to_var_tail_n s;
      t = t + 2;
      fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
      fst'_ret_state = fst'_imp fst'_state;
      t = t + fst'_imp_time 0 fst'_state;
      fst'_result = fst'_state_p fst'_ret_state;
      t = t + 2;
      cons_h' = fst'_result;
      t = t + 2;
      cons_t' = 0;
      t = t + 2;
      cons_ret' = 0;
      t = t + 2;
      cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
      cons_ret_state = cons_imp cons_state;
      t = t + cons_imp_time 0 cons_state;
      cons_result = cons_ret cons_ret_state;
      t = t + 2;
      operand_bit_to_var_acc_acc' = cons_result;
      t = t + 2;
      operand_bit_to_var_acc_n' = operand_bit_to_var_tail_n s;
      t = t + 2;
      operand_bit_to_var_acc_ret' = 0;
      t = t + 2;
      operand_bit_to_var_acc_state =
        \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',
         operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',
         operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>;
      operand_bit_to_var_acc_ret_state = operand_bit_to_var_acc_imp operand_bit_to_var_acc_state;
      t = t + operand_bit_to_var_acc_imp_time 0 operand_bit_to_var_acc_state;
      operand_bit_to_var_acc_result = operand_bit_to_var_acc_ret operand_bit_to_var_acc_ret_state;
      t = t + 2;
      operand_bit_to_var_tail_n' = operand_bit_to_var_tail_n s;
      t = t + 2;
      operand_bit_to_var_tail_ret' = operand_bit_to_var_acc_result;
      t = t + 2;
      ret = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n',
             operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>
    in
      t
  )"
  by auto
termination
  by (relation "measure (\<lambda>(t, s). operand_bit_to_var_tail_n s)") simp

lemmas [simp del] = operand_bit_to_var_tail_imp_time.simps

lemma operand_bit_to_var_tail_imp_time_acc:
  "(operand_bit_to_var_tail_imp_time (Suc t) s) = Suc (operand_bit_to_var_tail_imp_time t s)"
  by (induction t s rule: operand_bit_to_var_tail_imp_time.induct)
    ((subst (1 2) operand_bit_to_var_tail_imp_time.simps); (simp add: Let_def))

lemma operand_bit_to_var_tail_imp_time_acc_2_aux:
  "(operand_bit_to_var_tail_imp_time x s) = x + (operand_bit_to_var_tail_imp_time 0 s)"
  by (induction x arbitrary: s)
    (simp add: operand_bit_to_var_tail_imp_time_acc)+

lemma operand_bit_to_var_tail_imp_time_acc_2:
  "x \<noteq> 0 \<Longrightarrow> (operand_bit_to_var_tail_imp_time x s) = x + (operand_bit_to_var_tail_imp_time 0 s)"
  by (rule operand_bit_to_var_tail_imp_time_acc_2_aux)

lemma operand_bit_to_var_tail_imp_time_acc_3:
  "operand_bit_to_var_tail_imp_time (a + b) s = a + (operand_bit_to_var_tail_imp_time b s)"
  by (induction a arbitrary: b s) (simp add: operand_bit_to_var_tail_imp_time_acc)+

abbreviation "operand_bit_to_var_tail_fst'_result \<equiv> ''fst'_result''"
abbreviation "operand_bit_to_var_tail_cons_result \<equiv> ''cons_result''"
abbreviation
  "operand_bit_to_var_tail_operand_bit_to_var_tail_result \<equiv> ''operand_bit_to_var_tail_result''"

definition "operand_bit_to_var_tail_IMP_Minus \<equiv>
  \<comment> \<open>    fst'_state_p' = operand_bit_to_var_tail_n s;\<close>
  (fst'_prefix @ fst'_p_str) ::= (A (V operand_bit_to_var_tail_n_str));;
  \<comment> \<open>    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;\<close>
  \<comment> \<open>    fst'_ret_state = fst'_imp fst'_state;\<close>
  invoke_subprogram fst'_prefix fst'_IMP_Minus;;
  \<comment> \<open>    fst'_result = fst'_state_p fst'_ret_state;\<close>
  operand_bit_to_var_tail_fst'_result ::= (A (V (fst'_prefix @ fst'_p_str)));;
  \<comment> \<open>    cons_h' = fst'_result;\<close>
  (cons_prefix @ cons_h_str) ::= (A (V operand_bit_to_var_tail_fst'_result));;
  \<comment> \<open>    cons_t' = 0;\<close>
  (cons_prefix @ cons_t_str) ::= (A (N 0));;
  \<comment> \<open>    cons_ret' = 0;\<close>
  (cons_prefix @ cons_ret_str) ::= (A (N 0));;
  \<comment> \<open>    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;\<close>
  \<comment> \<open>    cons_ret_state = cons_imp cons_state;\<close>
  invoke_subprogram cons_prefix cons_IMP_Minus;;
  \<comment> \<open>    cons_result = cons_ret cons_ret_state;\<close>
  operand_bit_to_var_tail_cons_result ::= (A (V (cons_prefix @ cons_ret_str)));;
  \<comment> \<open>    operand_bit_to_var_acc_acc' = cons_result;\<close>
  (operand_bit_to_var_acc_prefix @ operand_bit_to_var_acc_acc_str) ::=
    (A (V operand_bit_to_var_tail_cons_result));;
  \<comment> \<open>    operand_bit_to_var_acc_n' = operand_bit_to_var_tail_n s;\<close>
  (operand_bit_to_var_acc_prefix @ operand_bit_to_var_acc_n_str) ::=
    (A (V operand_bit_to_var_tail_n_str));;
  \<comment> \<open>    operand_bit_to_var_acc_ret' = 0;\<close>
  (operand_bit_to_var_acc_prefix @ operand_bit_to_var_acc_ret_str) ::= (A (N 0));;
  \<comment> \<open>    operand_bit_to_var_acc_state =\<close>
  \<comment> \<open>      \<lparr>operand_bit_to_var_acc_acc = operand_bit_to_var_acc_acc',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_n = operand_bit_to_var_acc_n',\<close>
  \<comment> \<open>       operand_bit_to_var_acc_ret = operand_bit_to_var_acc_ret'\<rparr>;\<close>
  \<comment> \<open>    operand_bit_to_var_acc_ret_state =
            operand_bit_to_var_acc_imp operand_bit_to_var_acc_state;\<close>
  invoke_subprogram operand_bit_to_var_acc_prefix operand_bit_to_var_acc_IMP_Minus;;
  \<comment> \<open>    operand_bit_to_var_acc_result =
            operand_bit_to_var_acc_ret operand_bit_to_var_acc_ret_state;\<close>
  operand_bit_to_var_tail_operand_bit_to_var_tail_result ::=
    (A (V (operand_bit_to_var_acc_prefix @ operand_bit_to_var_acc_ret_str)));;
  \<comment> \<open>    operand_bit_to_var_tail_n' = operand_bit_to_var_tail_n s;\<close>
  operand_bit_to_var_tail_n_str ::= (A (V operand_bit_to_var_tail_n_str));;
  \<comment> \<open>    operand_bit_to_var_tail_ret' = operand_bit_to_var_acc_result;\<close>
  operand_bit_to_var_tail_ret_str ::= (A (V operand_bit_to_var_tail_operand_bit_to_var_tail_result))
  \<comment> \<open>    ret = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n',\<close>
  \<comment> \<open>           operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>\<close>
  "

abbreviation
  "operand_bit_to_var_tail_IMP_vars \<equiv>
  {operand_bit_to_var_tail_n_str, operand_bit_to_var_tail_ret_str,
   operand_bit_to_var_tail_fst'_result, operand_bit_to_var_tail_cons_result,
   operand_bit_to_var_tail_operand_bit_to_var_tail_result}"

definition "operand_bit_to_var_tail_imp_to_HOL_state p s =
  \<lparr>operand_bit_to_var_tail_n = (s (add_prefix p operand_bit_to_var_tail_n_str)),
   operand_bit_to_var_tail_ret = (s (add_prefix p operand_bit_to_var_tail_ret_str))\<rparr>"

lemmas operand_bit_to_var_tail_state_translators =
  fst'_imp_to_HOL_state_def
  cons_imp_to_HOL_state_def
  operand_bit_to_var_acc_imp_to_HOL_state_def
  operand_bit_to_var_tail_imp_to_HOL_state_def

lemma operand_bit_to_var_tail_IMP_Minus_correct_function:
  "(invoke_subprogram p operand_bit_to_var_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p operand_bit_to_var_tail_ret_str)
      = operand_bit_to_var_tail_ret
  (operand_bit_to_var_tail_imp (operand_bit_to_var_tail_imp_to_HOL_state p s))"
  apply(simp only: operand_bit_to_var_tail_IMP_Minus_def prefix_simps)
  apply(erule Seq_E)+
  apply(erule fst'_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(15) by fastforce
  apply(erule cons_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(17) by fastforce
  apply(erule operand_bit_to_var_acc_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(19) by fastforce
  by (fastforce simp: operand_bit_to_var_tail_state_translators operand_bit_to_var_tail_imp.simps
      operand_bit_to_var_tail_state_upd_def)

lemma operand_bit_to_var_tail_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ operand_bit_to_var_tail_pref) operand_bit_to_var_tail_IMP_Minus, s)
      \<Rightarrow>\<^bsup>t\<^esup> s'; v \<in> vars; \<not> (prefix operand_bit_to_var_tail_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma operand_bit_to_var_tail_IMP_Minus_correct_time:
  "(invoke_subprogram p operand_bit_to_var_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = operand_bit_to_var_tail_imp_time 0 (operand_bit_to_var_tail_imp_to_HOL_state p s)"
  apply(simp only: operand_bit_to_var_tail_IMP_Minus_def prefix_simps)
  apply(erule Seq_tE)+
  apply(erule fst'_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(29) by fastforce
  apply(erule cons_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(31) by fastforce
  apply(erule operand_bit_to_var_acc_IMP_Minus_correct[where vars=operand_bit_to_var_tail_IMP_vars])
  subgoal premises p using p(33) by fastforce
  by (fastforce simp: operand_bit_to_var_tail_state_translators Let_def
      operand_bit_to_var_tail_imp_time.simps operand_bit_to_var_tail_state_upd_def )

lemma operand_bit_to_var_tail_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) operand_bit_to_var_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (operand_bit_to_var_tail_imp_time 0
            (operand_bit_to_var_tail_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) operand_bit_to_var_tail_ret_str) =
        operand_bit_to_var_tail_ret
          (operand_bit_to_var_tail_imp (operand_bit_to_var_tail_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using operand_bit_to_var_tail_IMP_Minus_correct_time
    operand_bit_to_var_tail_IMP_Minus_correct_function
    operand_bit_to_var_tail_IMP_Minus_correct_effects
  by (meson set_mono_prefix)


subsection \<open>var_to_operand_bit_nat\<close>

subsubsection \<open>var_to_operand_bit_tail\<close>


fun var_to_operand_bit_tail':: "nat \<Rightarrow> nat" where
  "var_to_operand_bit_tail' v  =
  (
  (if v \<noteq> 0 then (
  let r = (prod_encode (hd_nat v, length_nat v - 1)) in 
    if  v = operand_bit_to_var_tail r
   then r + 1 else 0)
   else 0))"

lemma var_to_operand_bit_tail'_correct:
  "var_to_operand_bit_tail' v = var_to_operand_bit_tail v"
  unfolding var_to_operand_bit_tail_def
  using some_nat_def var_to_operand_bit_tail'.simps by presburger

record var_to_operand_bit_tail_state =
  var_to_operand_bit_tail_v::nat
  var_to_operand_bit_tail_ret::nat

abbreviation "var_to_operand_bit_tail_prefix \<equiv> ''var_to_operand_bit_tail.''"
abbreviation "var_to_operand_bit_tail_v_str \<equiv> ''v''"
abbreviation "var_to_operand_bit_tail_ret_str \<equiv> ''ret''"

definition "var_to_operand_bit_tail_state_upd s =
  (
    (if var_to_operand_bit_tail_v s \<noteq> 0 then
      (let
      hd_xs' = var_to_operand_bit_tail_v s;
      hd_ret' = 0;
      hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
      hd_ret_state = hd_imp hd_state;
      hd_result = hd_ret hd_ret_state;
      length_xs' = var_to_operand_bit_tail_v s;
      length_ret' = 0;
      length_state = \<lparr>length_xs = length_xs', length_ret = length_ret'\<rparr>;
      length_ret_state = length_imp length_state;
      length_result = length_ret length_ret_state;
      prod_encode_a' = hd_result;
      prod_encode_b' = length_result - 1;
      prod_encode_ret' = 0;
      prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',prod_encode_b = prod_encode_b', prod_encode_ret = prod_encode_ret'\<rparr>;
      prod_encode_ret_state = prod_encode_imp prod_encode_state;
      prod_encode_result = prod_encode_ret prod_encode_ret_state;
      operand_bit_to_var_tail_n' = prod_encode_result;
      operand_bit_to_var_tail_ret' = 0;
      operand_bit_to_var_tail_state = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n', operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>;
      operand_bit_to_var_tail_ret_state = operand_bit_to_var_tail_imp operand_bit_to_var_tail_state;
      operand_bit_to_var_tail_res = operand_bit_to_var_tail_ret operand_bit_to_var_tail_ret_state;
      EQUAL_neq_zero_a' = var_to_operand_bit_tail_v s;
      EQUAL_neq_zero_b' = operand_bit_to_var_tail_res;
      EQUAL_neq_zero_ret' = 0;
      EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',EQUAL_neq_zero_b = EQUAL_neq_zero_b', EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;
      EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;
      EQUAL_neq_zero_res = EQUAL_neq_zero_ret EQUAL_neq_zero_ret_state;
      var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;
      var_to_operand_bit_tail_ret' = (if EQUAL_neq_zero_res \<noteq> 0 
        then (prod_encode_result + 1)
        else 0
      );
      ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
             var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>
      in
        ret
      )

    else
      let 
        var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;
        var_to_operand_bit_tail_ret' = 0;
        ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
               var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>
      in ret
   )
)"


lemmas var_to_operand_bit_tail_imp_subprogram_simps =
  var_to_operand_bit_tail_state_upd_def

function var_to_operand_bit_tail_imp:: 
"var_to_operand_bit_tail_state \<Rightarrow> var_to_operand_bit_tail_state" where
  "var_to_operand_bit_tail_imp s =
  (let
      ret = var_to_operand_bit_tail_state_upd s
    in
      ret
  )"by auto
termination 
  by (relation "measure (\<lambda>(s). var_to_operand_bit_tail_v s)") simp

declare var_to_operand_bit_tail_imp.simps [simp del]

lemma var_to_operand_bit_tail_imp_correct:
  "var_to_operand_bit_tail_ret (var_to_operand_bit_tail_imp s) =
    var_to_operand_bit_tail' (var_to_operand_bit_tail_v s)"
  apply (simp add: var_to_operand_bit_tail_imp.simps var_to_operand_bit_tail_state_upd_def
     operand_bit_to_var_tail_imp_correct hd_imp_correct 
     length_imp_correct prod_encode_imp_correct 
     AND_neq_zero_imp_correct EQUAL_neq_zero_imp_correct)
  apply (simp only: var_to_operand_bit_tail_def
       hd_nat_def)
  by (smt (verit, ccfv_threshold) Nat.add_0_right One_nat_def add_Suc_right diff_zero length_imp_correct length_state.ext_inject length_state.surjective lessI prod.simps(2) prod_encode_def some_nat_def var_to_operand_bit_tail_state.select_convs(2) zero_less_iff_neq_zero)

function var_to_operand_bit_tail_imp_time:: 
"nat \<Rightarrow> var_to_operand_bit_tail_state \<Rightarrow> nat" where
  "var_to_operand_bit_tail_imp_time t s =
    (if var_to_operand_bit_tail_v s \<noteq> 0 then
        (let
      t = t + 1;
      hd_xs' = var_to_operand_bit_tail_v s;
      t = t + 2;
      hd_ret' = 0;
      t = t + 2;
      hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
      hd_ret_state = hd_imp hd_state;
      t = t + hd_imp_time 0 hd_state;
      hd_result = hd_ret hd_ret_state;
      t = t + 2;
      length_xs' = var_to_operand_bit_tail_v s;
      t = t + 2;
      length_ret' = 0;
      t = t + 2;
      length_state = \<lparr>length_xs = length_xs', length_ret = length_ret'\<rparr>;
      length_ret_state = length_imp length_state;
      t = t + length_imp_time 0 length_state;
      length_result = length_ret length_ret_state;
      t = t + 2;
      prod_encode_a' = hd_result;
      t = t + 2;
      prod_encode_b' = length_result - 1;
      t = t + 2;
      prod_encode_ret' = 0;
      t = t + 2;
      prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',prod_encode_b = prod_encode_b', prod_encode_ret = prod_encode_ret'\<rparr>;
      prod_encode_ret_state = prod_encode_imp prod_encode_state;
      t = t + prod_encode_imp_time 0 prod_encode_state;
      prod_encode_result = prod_encode_ret prod_encode_ret_state;
      t = t + 2;
      operand_bit_to_var_tail_n' = prod_encode_result;
      t = t + 2;
      operand_bit_to_var_tail_ret' = 0;
      t = t + 2;
      operand_bit_to_var_tail_state = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n', operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>;
      operand_bit_to_var_tail_ret_state = operand_bit_to_var_tail_imp operand_bit_to_var_tail_state;
      t = t + operand_bit_to_var_tail_imp_time 0 operand_bit_to_var_tail_state;
      operand_bit_to_var_tail_res = operand_bit_to_var_tail_ret operand_bit_to_var_tail_ret_state;
      t = t + 2;
      EQUAL_neq_zero_a' = var_to_operand_bit_tail_v s;
      t = t + 2;
      EQUAL_neq_zero_b' = operand_bit_to_var_tail_res;
      t = t + 2;
      EQUAL_neq_zero_ret' = 0;
      t = t + 2;
      EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',EQUAL_neq_zero_b = EQUAL_neq_zero_b', EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;
      EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;
      t = t + EQUAL_neq_zero_imp_time 0 EQUAL_neq_zero_state;
      EQUAL_neq_zero_res = EQUAL_neq_zero_ret EQUAL_neq_zero_ret_state;
      t = t + 2;
      var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;
      t = t + 2;
      var_to_operand_bit_tail_ret' = (if EQUAL_neq_zero_res \<noteq> 0 
        then
         (prod_encode_result + 1)
        else 0
      );
      t = t + 1 + (if EQUAL_neq_zero_res \<noteq> 0 
        then 2
        else 2
      );
      t = t + 2;
      ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
             var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>
    in
      t
  ) 
  else let 
      t = t + 2;
      var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;
      t = t + 2;
      var_to_operand_bit_tail_ret' = 0;
      t = t + 2;
      ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
             var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>
 in t)"
  by auto
termination
  by (relation "measure (\<lambda>(t, s). var_to_operand_bit_tail_v s)") simp

lemmas [simp del] = var_to_operand_bit_tail_imp_time.simps

lemma var_to_operand_bit_tail_imp_time_acc:
  "(var_to_operand_bit_tail_imp_time (Suc t) s) = Suc (var_to_operand_bit_tail_imp_time t s)"
  by (induction t s rule: var_to_operand_bit_tail_imp_time.induct)
    ((subst (1 2) var_to_operand_bit_tail_imp_time.simps); (simp add: Let_def))

lemma var_to_operand_bit_tail_imp_time_acc_2_aux:
  "(var_to_operand_bit_tail_imp_time x s) = x + (var_to_operand_bit_tail_imp_time 0 s)"
  by (induction x arbitrary: s)
    (simp add: var_to_operand_bit_tail_imp_time_acc)+

lemma var_to_operand_bit_tail_imp_time_acc_2:
  "x \<noteq> 0 \<Longrightarrow> (var_to_operand_bit_tail_imp_time x s) = x + (var_to_operand_bit_tail_imp_time 0 s)"
  by (rule var_to_operand_bit_tail_imp_time_acc_2_aux)

lemma var_to_operand_bit_tail_imp_time_acc_3:
  "var_to_operand_bit_tail_imp_time (a + b) s = a + (var_to_operand_bit_tail_imp_time b s)"
  by (induction a arbitrary: b s) (simp add: var_to_operand_bit_tail_imp_time_acc)+

abbreviation "var_to_operand_bit_tail_hd_result \<equiv> ''hd_result''"
abbreviation "var_to_operand_bit_tail_length_result \<equiv> ''length_result''"
abbreviation "var_to_operand_bit_tail_prod_encode_result \<equiv> ''prod_encode_result''"
abbreviation
  "var_to_operand_bit_tail_operand_bit_to_var_tail_result \<equiv> 
    ''operand_bit_to_var_tail_result''"
abbreviation "var_to_operand_bit_tail_EQUAL_neq_zero_ret_result \<equiv> ''EQUAL_neq_zero_ret_result''"
abbreviation "var_to_operand_bit_tail_AND_neq_zero_ret_result \<equiv> ''AND_neq_zero_ret_result''"
abbreviation "var_to_operand_bit_tail_cond \<equiv> ''cond''"

definition "var_to_operand_bit_tail_IMP_Minus \<equiv>
  IF var_to_operand_bit_tail_v_str \<noteq>0 THEN (
  \<comment> \<open>hd_xs' = var_to_operand_bit_tail_v s;\<close>
  (hd_prefix @ hd_xs_str) ::= (A (V var_to_operand_bit_tail_v_str));;
  \<comment> \<open>hd_ret' = 0;\<close>
  (hd_prefix @ hd_ret_str) ::= (A (N 0));;
  \<comment> \<open>hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;\<close>
  \<comment> \<open>hd_ret_state = hd_imp hd_state;\<close>
  invoke_subprogram hd_prefix hd_IMP_Minus;;
  \<comment> \<open>hd_result = hd_ret hd_ret_state;\<close>
  var_to_operand_bit_tail_hd_result ::= (A (V (hd_prefix @ hd_ret_str)));;
  \<comment> \<open>length_xs' = var_to_operand_bit_tail_v s;\<close>
  (length_prefix @ length_xs_str) ::= (A (V var_to_operand_bit_tail_v_str));;
  \<comment> \<open>length_ret' = 0;\<close>
  (length_prefix @ length_ret_str) ::= (A (N 0));;
  \<comment> \<open>length_state = \<lparr>length_xs = length_xs', length_ret = length_ret'\<rparr>;\<close>
  \<comment> \<open>length_ret_state = length_imp length_state;\<close>
  invoke_subprogram length_prefix length_IMP_Minus;;
  \<comment> \<open>length_result = length_ret length_ret_state;\<close>
  var_to_operand_bit_tail_length_result ::= (A (V (length_prefix @ length_ret_str)));;
  \<comment> \<open>prod_encode_a' = hd_result;\<close>
  (prod_encode_prefix @ prod_encode_a_str) ::= (A (V var_to_operand_bit_tail_hd_result));;
  \<comment> \<open>prod_encode_b' = length_result - 1;\<close>
  (prod_encode_prefix @ prod_encode_b_str) ::= (Sub (V var_to_operand_bit_tail_length_result) (N 1));;
  \<comment> \<open>prod_encode_ret' = 0;\<close>
  (prod_encode_prefix @ prod_encode_ret_str) ::= (A (N 0));;
  \<comment> \<open>prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
            prod_encode_b = prod_encode_b', prod_encode_ret = prod_encode_ret'\<rparr>;\<close>
  \<comment> \<open>prod_encode_ret_state = prod_encode_imp prod_encode_state;\<close>
  invoke_subprogram prod_encode_prefix prod_encode_IMP_Minus;;
  \<comment> \<open>prod_encode_result = prod_encode_ret prod_encode_ret_state;\<close>
  var_to_operand_bit_tail_prod_encode_result ::= (A (V (prod_encode_prefix @ prod_encode_ret_str)));;
  \<comment> \<open>operand_bit_to_var_tail_n' = prod_encode_result;\<close>
  (operand_bit_to_var_tail_prefix @ operand_bit_to_var_tail_n_str) ::= 
    (A (V var_to_operand_bit_tail_prod_encode_result));;
  \<comment> \<open>operand_bit_to_var_tail_ret' = 0;\<close>
  (operand_bit_to_var_tail_prefix @ operand_bit_to_var_tail_ret_str) ::= 
    (A (N 0));;
  \<comment> \<open>operand_bit_to_var_tail_state = \<lparr>operand_bit_to_var_tail_n = operand_bit_to_var_tail_n', operand_bit_to_var_tail_ret = operand_bit_to_var_tail_ret'\<rparr>;\<close>
  \<comment> \<open>operand_bit_to_var_tail_ret_state = operand_bit_to_var_tail_imp operand_bit_to_var_tail_state;\<close>
  invoke_subprogram operand_bit_to_var_tail_prefix operand_bit_to_var_tail_IMP_Minus;;
  \<comment> \<open>operand_bit_to_var_tail_res = operand_bit_to_var_tail_ret operand_bit_to_var_tail_ret_state;\<close>
  var_to_operand_bit_tail_operand_bit_to_var_tail_result ::=
    (A (V (operand_bit_to_var_tail_prefix @ operand_bit_to_var_tail_ret_str)));;
  \<comment> \<open>EQUAL_neq_zero_a' = var_to_operand_bit_tail_v s;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_a_str) ::= (A (V var_to_operand_bit_tail_v_str));;
  \<comment> \<open>EQUAL_neq_zero_b' = operand_bit_to_var_tail_res;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_b_str) ::= 
      (A (V var_to_operand_bit_tail_operand_bit_to_var_tail_result));;
  \<comment> \<open>EQUAL_neq_zero_ret' = 0;\<close>
  (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_ret_str) ::= (A (N 0));;
  \<comment> \<open>EQUAL_neq_zero_state = \<lparr>EQUAL_neq_zero_a = EQUAL_neq_zero_a',EQUAL_neq_zero_b = EQUAL_neq_zero_b', EQUAL_neq_zero_ret = EQUAL_neq_zero_ret'\<rparr>;\<close>
  \<comment> \<open>EQUAL_neq_zero_ret_state = EQUAL_neq_zero_imp EQUAL_neq_zero_state;\<close>
  invoke_subprogram EQUAL_neq_zero_prefix EQUAL_neq_zero_IMP_Minus;;
  \<comment> \<open>EQUAL_neq_zero_res = EQUAL_neq_zero_ret EQUAL_neq_zero_ret_state;\<close>
  var_to_operand_bit_tail_EQUAL_neq_zero_ret_result ::=
    (A (V (EQUAL_neq_zero_prefix @ EQUAL_neq_zero_ret_str)));;
  \<comment> \<open>var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;\<close>
  var_to_operand_bit_tail_v_str ::= (A (V var_to_operand_bit_tail_v_str));;
  \<comment> \<open>var_to_operand_bit_tail_ret' = (if cond \<noteq> 0 
        then
         (prod_encode_result + 1)
        else 0
      );\<close>
  IF var_to_operand_bit_tail_EQUAL_neq_zero_ret_result \<noteq>0 THEN
      var_to_operand_bit_tail_ret_str ::= 
        (Plus (V var_to_operand_bit_tail_prod_encode_result) (N 1))
  ELSE 
      var_to_operand_bit_tail_ret_str ::= (A (N 0))
  \<comment> \<open>ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
             var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>\<close>
) ELSE 
  \<comment> \<open>var_to_operand_bit_tail_v' = var_to_operand_bit_tail_v s;\<close>
  var_to_operand_bit_tail_v_str ::= (A (V var_to_operand_bit_tail_v_str));;
  \<comment> \<open>var_to_operand_bit_tail_ret' = 0 \<close>
  var_to_operand_bit_tail_ret_str ::= (A (N 0))"
  \<comment> \<open>ret = \<lparr>var_to_operand_bit_tail_v = var_to_operand_bit_tail_v',
             var_to_operand_bit_tail_ret = var_to_operand_bit_tail_ret'\<rparr>\<close>

abbreviation
  "var_to_operand_bit_tail_IMP_vars \<equiv>
  {var_to_operand_bit_tail_v_str, var_to_operand_bit_tail_ret_str,
   var_to_operand_bit_tail_hd_result, var_to_operand_bit_tail_prod_encode_result,
   var_to_operand_bit_tail_operand_bit_to_var_tail_result,
  var_to_operand_bit_tail_EQUAL_neq_zero_ret_result, 
  var_to_operand_bit_tail_AND_neq_zero_ret_result, var_to_operand_bit_tail_cond}"

definition "var_to_operand_bit_tail_imp_to_HOL_state p s =
  \<lparr>var_to_operand_bit_tail_v = (s (add_prefix p var_to_operand_bit_tail_v_str)),
   var_to_operand_bit_tail_ret = (s (add_prefix p var_to_operand_bit_tail_ret_str))\<rparr>"

lemmas var_to_operand_bit_tail_state_translators =
  hd_imp_to_HOL_state_def
  length_imp_to_HOL_state_def
  prod_encode_imp_to_HOL_state_def
  operand_bit_to_var_tail_imp_to_HOL_state_def
  EQUAL_neq_zero_imp_to_HOL_state_def
  AND_neq_zero_imp_to_HOL_state_def
  var_to_operand_bit_tail_imp_to_HOL_state_def


lemma var_to_operand_bit_tail_IMP_Minus_correct_function:
  "(invoke_subprogram p var_to_operand_bit_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p var_to_operand_bit_tail_ret_str)
      = var_to_operand_bit_tail_ret
  (var_to_operand_bit_tail_imp (var_to_operand_bit_tail_imp_to_HOL_state p s))"


  apply(subst var_to_operand_bit_tail_imp.simps)
  apply(simp only: var_to_operand_bit_tail_IMP_Minus_def prefix_simps)
  apply (erule Seq_E)
  apply (erule If_E)
   apply (erule Seq_E)+
  subgoal
    apply (simp only: var_to_operand_bit_tail_imp_subprogram_simps)
    apply (simp only: Let_def)
    apply (simp only: split: if_split)
  apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
    subgoal premises p using p(26) by fastforce
    apply (thin_tac "_ = EQUAL_neq_zero_imp_time (0::nat) _" for x)
  apply(erule operand_bit_to_var_tail_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(27) operand_bit_to_var_tail_imp_to_HOL_state_def by fastforce
  apply (thin_tac "_ = operand_bit_to_var_tail_imp_time (0::nat) _" for x)
  apply(erule prod_encode_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(28) prod_encode_imp_to_HOL_state_def by fastforce
  apply (thin_tac "_ = prod_encode_imp_time (0::nat) _" for x)
  apply(erule length_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(29) length_imp_to_HOL_state_def by fastforce
    apply (thin_tac "_ = length_imp_time (0::nat) _" for x)
  apply(erule hd_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(30) by fastforce
    apply (thin_tac "_ = hd_imp_time (0::nat) _" for x)
    apply (simp only: var_to_operand_bit_tail_imp_to_HOL_state_def)
    apply (simp only: hd_imp_to_HOL_state_def)
    apply (simp only: length_imp_to_HOL_state_def) 
    apply (simp only: prod_encode_imp_to_HOL_state_def)
    apply (simp only: operand_bit_to_var_tail_imp_to_HOL_state_def)
    apply (simp only: EQUAL_neq_zero_imp_to_HOL_state_def)
  apply (erule If_tE)
  subgoal
    sorry
    sorry
  by (fastforce simp: var_to_operand_bit_tail_imp_subprogram_simps
      var_to_operand_bit_tail_state_translators)
  subgoal            
      apply (vcg var_to_operand_bit_tail_IMP_vars)
   
  sorry                                            
  apply (fastforce_sorted_premises simp: var_to_operand_bit_tail_imp_subprogram_simps
      var_to_operand_bit_tail_state_translators)
 apply (fastforce simp: var_to_operand_bit_tail_imp_subprogram_simps
      var_to_operand_bit_tail_state_translators)

  subgoal premises p
    using p
    
    subgoal
      sorry

    
    sorry
  sorry
  apply(erule hd_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(30) by fastforce
  apply(erule length_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(32) by fastforce
  apply(erule prod_encode_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(34) by fastforce
  apply(erule operand_bit_to_var_tail_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(36) by fastforce
  apply(erule EQUAL_neq_zero_IMP_Minus_correct[where vars=var_to_operand_bit_tail_IMP_vars])
  subgoal premises p using p(38) by fastforce
  apply (erule If_tE)
  subgoal 
    apply (fastforce_sorted_premises simp: var_to_operand_bit_tail_imp_subprogram_simps
        var_to_operand_bit_tail_state_translators Let_def)
  subgoal premises p using p sorry
  done

lemma var_to_operand_bit_tail_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ var_to_operand_bit_tail_pref) var_to_operand_bit_tail_IMP_Minus, s)
      \<Rightarrow>\<^bsup>t\<^esup> s'; v \<in> vars; \<not> (prefix var_to_operand_bit_tail_pref v)\<rbrakk>
  \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemma var_to_operand_bit_tail_IMP_Minus_correct_time:
  "(invoke_subprogram p var_to_operand_bit_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = var_to_operand_bit_tail_imp_time 0 (var_to_operand_bit_tail_imp_to_HOL_state p s)"
  sorry

lemma var_to_operand_bit_tail_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) var_to_operand_bit_tail_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
     \<lbrakk>t = (var_to_operand_bit_tail_imp_time 0
            (var_to_operand_bit_tail_imp_to_HOL_state (p1 @ p2) s));
      s' (add_prefix (p1 @ p2) var_to_operand_bit_tail_ret_str) =
        var_to_operand_bit_tail_ret
          (var_to_operand_bit_tail_imp (var_to_operand_bit_tail_imp_to_HOL_state (p1 @ p2) s));
      \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
     \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using var_to_operand_bit_tail_IMP_Minus_correct_time
    var_to_operand_bit_tail_IMP_Minus_correct_function
    var_to_operand_bit_tail_IMP_Minus_correct_effects
  by (meson set_mono_prefix)





subsection \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial\<close>

subsubsection \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc\<close>

fun map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc':: "nat \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> nat" where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc' acc k n =
    (if n \<noteq> 0
     then
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc'
       ((prod_encode (fst_nat (hd_nat n), nth_bit_tail (snd_nat (hd_nat n)) k)) ## acc) k (tl_nat n)
     else acc
    )"

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc'_correct:
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc' acc k n =
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc acc k n"
  by(induction acc k n rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc.induct)
    (simp add: subtail_nth_bit)

record map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc::nat
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k::nat
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n::nat
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret::nat

abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_prefix \<equiv>
  ''map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc.''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str \<equiv> ''acc''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str \<equiv> ''k''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str \<equiv> ''n''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str \<equiv> ''ret''"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd s \<equiv>
  let
    hd_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    hd_ret' = 0;
    hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
    hd_ret_state = hd_imp hd_state;
    hd_result = hd_ret hd_ret_state;
    tl_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    tl_ret' = 0;
    tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;
    tl_ret_state = tl_imp tl_state;
    tl_result = tl_ret tl_ret_state;
    fst'_state_p' = hd_result;
    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
    fst'_ret_state = fst'_imp fst'_state;
    fst'_result = fst'_state_p fst'_ret_state;
    snd'_state_p' = hd_result;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    snd'_result = snd'_state_p snd'_ret_state;
    nth_bit_tail_acc' = snd'_result;
    nth_bit_tail_n' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    nth_bit_tail_ret' = 0;
    nth_bit_tail_state = \<lparr>nth_bit_tail_acc = nth_bit_tail_acc',
                          nth_bit_tail_n = nth_bit_tail_n',
                          nth_bit_tail_ret = nth_bit_tail_ret'\<rparr>;
    nth_bit_tail_ret_state = nth_bit_tail_imp nth_bit_tail_state;
    nth_bit_tail_result = nth_bit_tail_ret nth_bit_tail_ret_state;
    prod_encode_a' = fst'_result;
    prod_encode_b' = nth_bit_tail_result;
    prod_encode_ret' = 0;
    prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
                         prod_encode_b = prod_encode_b',
                         prod_encode_ret = prod_encode_ret'\<rparr>;
    prod_encode_ret_state = prod_encode_imp prod_encode_state;
    prod_result = prod_encode_ret prod_encode_ret_state;
    cons_h' = prod_result;
    cons_t' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    cons_ret' = 0;
    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
    cons_ret_state = cons_imp cons_state;
    cons_result = cons_ret cons_ret_state;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' = cons_result;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' = tl_result;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret s;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
  in ret
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition s \<equiv>
  let
    condition = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s
  in condition
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop s \<equiv>
  let
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
  in ret
"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_def

function map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp::
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state \<Rightarrow>
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state"
  where
    "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp s =
  (if map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition s \<noteq> 0
   then
    let next_iteration =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp
        (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd s)
    in next_iteration
   else
    let ret = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop s
    in ret
  )"
  by simp+
termination
  apply (relation "measure map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n")
  by (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
      hd_imp_correct tl_imp_correct fst'_imp_correct snd'_imp_correct nth_bit_tail_imp_correct
      prod_encode_imp_correct cons_imp_correct Let_def)+

declare map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps [simp del]

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_correct:
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret
    (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp s) =
   map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc'
    (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s)
    (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s)
    (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s)"
  apply (induction s rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply (subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps)
  apply (subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc'.simps)
  by (simp del: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc'.simps
      add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps Let_def
      fst_nat_fst'_nat snd_nat_snd'_nat hd_imp_correct tl_imp_correct fst'_imp_correct
      snd'_imp_correct nth_bit_tail_imp_correct prod_encode_imp_correct cons_imp_correct
      nth_bit_tail'_correct)

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time t s \<equiv>
  let
    hd_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + 2;
    hd_ret' = 0;
    t = t + 2;
    hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
    hd_ret_state = hd_imp hd_state;
    t = t + hd_imp_time 0 hd_state;
    hd_result = hd_ret hd_ret_state;
    t = t + 2;
    tl_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + 2;
    tl_ret' = 0;
    t = t + 2;
    tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;
    tl_ret_state = tl_imp tl_state;
    t = t + tl_imp_time 0 tl_state;
    tl_result = tl_ret tl_ret_state;
    t = t + 2;
    fst'_state_p' = hd_result;
    t = t + 2;
    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
    fst'_ret_state = fst'_imp fst'_state;
    t = t + fst'_imp_time 0 fst'_state;
    fst'_result = fst'_state_p fst'_ret_state;
    t = t + 2;
    snd'_state_p' = hd_result;
    t = t + 2;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    snd'_ret_state = snd'_imp snd'_state;
    t = t + snd'_imp_time 0 snd'_state;
    snd'_result = snd'_state_p snd'_ret_state;
    t = t + 2;
    nth_bit_tail_acc' = snd'_result;
    t = t + 2;
    nth_bit_tail_n' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + 2;
    nth_bit_tail_ret' = 0;
    t = t + 2;
    nth_bit_tail_state = \<lparr>nth_bit_tail_acc = nth_bit_tail_acc',
                          nth_bit_tail_n = nth_bit_tail_n',
                          nth_bit_tail_ret = nth_bit_tail_ret'\<rparr>;
    nth_bit_tail_ret_state = nth_bit_tail_imp nth_bit_tail_state;
    t = t + nth_bit_tail_imp_time 0 nth_bit_tail_state;
    nth_bit_tail_result = nth_bit_tail_ret nth_bit_tail_ret_state;
    t = t + 2;
    prod_encode_a' = fst'_result;
    t = t + 2;
    prod_encode_b' =nth_bit_tail_result;
    t = t + 2;
    prod_encode_ret' = 0;
    t = t + 2;
    prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
                         prod_encode_b = prod_encode_b',
                         prod_encode_ret = prod_encode_ret'\<rparr>;
    prod_encode_ret_state = prod_encode_imp prod_encode_state;
    t = t + prod_encode_imp_time 0 prod_encode_state;
    prod_result = prod_encode_ret prod_encode_ret_state;
    t = t + 2;
    cons_h' = prod_result;
    t = t + 2;
    cons_t' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + 2;
    cons_ret' = 0;
    t = t + 2;
    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
    cons_ret_state = cons_imp cons_state;
    t = t + cons_imp_time 0 cons_state;
    cons_result = cons_ret cons_ret_state;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' = cons_result;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' = tl_result;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret s;
    t = t + 2;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
  in
    t
"

definition
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time t s \<equiv>
  let
    condition = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + 2
  in
    t
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time t s \<equiv>
  let
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + 2;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + 2;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
  in
    t
"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps

function map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time::
  "nat \<Rightarrow> map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state \<Rightarrow> nat" where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time 0 s +
  (if map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition s \<noteq> 0
    then
      (let
        t = t + 1;
        next_iteration =
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time
            (t + map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time 0 s)
            (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd s)
       in next_iteration)
    else
      (let
        t = t + 2;
        ret = t + map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time 0 s
       in ret)
  )"
  by auto
termination
  by (relation "measure (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n \<circ> snd)")
    (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps
      tl_imp_correct Let_def)+

declare map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps [simp del]

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time (Suc t) s) =
    Suc (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s)"
  by (induction t s rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.induct)
    ((subst (1 2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps);
      (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_def))

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2_aux:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s) =
    t + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 s)"
  by (induction t arbitrary: s)
    (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc)+

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2:
  "t \<noteq> 0 \<Longrightarrow> (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s) =
    t + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 s)"
  by (rule map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2_aux)

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_3:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time (a + b) s) =
    a + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time b s)"
  by (induction a arbitrary: b s)
    (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc)+

abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_while_cond \<equiv> ''condition''"

abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_hd_result \<equiv> ''hd_result''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_tl_result \<equiv> ''tl_result''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_fst'_result \<equiv> ''fst'_result''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_snd'_result \<equiv> ''snd'_result''"
abbreviation
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_nth_bit_tail_result \<equiv> ''nth_bit_tail_result''"
abbreviation
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_prod_encode_result \<equiv> ''prod_encode_result''"
abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_cons_result \<equiv> ''cons_result''"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond \<equiv>
  \<comment> \<open>condition = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_while_cond ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str))
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body \<equiv>
  \<comment> \<open>hd_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  (hd_prefix @ hd_xs_str) ::= (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str));;
  \<comment> \<open>hd_ret' = 0;\<close>
  (hd_prefix @ hd_ret_str) ::= (A (N 0));;
  \<comment> \<open>hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;\<close>
  \<comment> \<open>hd_ret_state = hd_imp hd_state;\<close>
  invoke_subprogram hd_prefix hd_IMP_Minus;;
  \<comment> \<open>hd_result = hd_ret hd_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_hd_result ::=
    (A (V (hd_prefix @ hd_ret_str)));;
  \<comment> \<open>tl_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  (tl_prefix @ tl_xs_str) ::= (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str));;
  \<comment> \<open>tl_ret' = 0;\<close>
  (tl_prefix @ tl_ret_str) ::= (A (N 0));;
  \<comment> \<open>tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;\<close>
  \<comment> \<open>tl_ret_state = tl_imp tl_state;\<close>
  invoke_subprogram tl_prefix tl_IMP_Minus;;
  \<comment> \<open>tl_result = tl_ret tl_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_tl_result ::=
    (A (V (tl_prefix @ tl_ret_str)));;
  \<comment> \<open>fst'_state_p' = hd_result;\<close>
  (fst'_prefix @ fst'_p_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_hd_result));;
  \<comment> \<open>fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;\<close>
  \<comment> \<open>fst'_ret_state = fst'_imp fst'_state;\<close>
  invoke_subprogram fst'_prefix fst'_IMP_Minus;;
  \<comment> \<open>fst'_result = fst'_state_p fst'_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_fst'_result ::=
    (A (V (fst'_prefix @ fst'_p_str)));;
  \<comment> \<open>snd'_state_p' = hd_result;\<close>
  (snd'_prefix @ snd'_p_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_hd_result));;
  \<comment> \<open>snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;\<close>
  \<comment> \<open>snd'_ret_state = snd'_imp snd'_state;\<close>
  invoke_subprogram snd'_prefix snd'_IMP_Minus;;
  \<comment> \<open>snd'_result = snd'_state_p snd'_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_snd'_result ::=
    (A (V (snd'_prefix @ snd'_p_str)));;
  \<comment> \<open>nth_bit_tail_acc' = snd'_result;\<close>
  (nth_bit_tail_prefix @ nth_bit_tail_acc_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_snd'_result));;
  \<comment> \<open>nth_bit_tail_n' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  (nth_bit_tail_prefix @ nth_bit_tail_n_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str));;
  \<comment> \<open>nth_bit_tail_ret' = 0;\<close>
  (nth_bit_tail_prefix @ nth_bit_tail_ret_str) ::= (A (N 0));;
  \<comment> \<open>nth_bit_tail_state = \<lparr>nth_bit_tail_acc = nth_bit_tail_acc',\<close>
  \<comment> \<open>                      nth_bit_tail_n = nth_bit_tail_n',\<close>
  \<comment> \<open>                      nth_bit_tail_ret = nth_bit_tail_ret'\<rparr>;\<close>
  \<comment> \<open>nth_bit_tail_ret_state = nth_bit_tail_imp nth_bit_tail_state;\<close>
  invoke_subprogram nth_bit_tail_prefix nth_bit_tail_IMP_Minus;;
  \<comment> \<open>nth_bit_tail_result = nth_bit_tail_ret nth_bit_tail_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_nth_bit_tail_result ::=
    (A (V (nth_bit_tail_prefix @ nth_bit_tail_ret_str)));;
  \<comment> \<open>prod_encode_a' = fst'_result;\<close>
  (prod_encode_prefix @ prod_encode_a_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_fst'_result));;
  \<comment> \<open>prod_encode_b' =nth_bit_tail_result;\<close>
  (prod_encode_prefix @ prod_encode_b_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_nth_bit_tail_result));;
  \<comment> \<open>prod_encode_ret' = 0;\<close>
  (prod_encode_prefix @ prod_encode_ret_str) ::= (A (N 0));;
  \<comment> \<open>prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',\<close>
  \<comment> \<open>                     prod_encode_b = prod_encode_b',\<close>
  \<comment> \<open>                     prod_encode_ret = prod_encode_ret'\<rparr>;\<close>
  \<comment> \<open>prod_encode_ret_state = prod_encode_imp prod_encode_state;\<close>
  invoke_subprogram prod_encode_prefix prod_encode_IMP_Minus;;
  \<comment> \<open>prod_result = prod_encode_ret prod_encode_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_prod_encode_result ::=
    (A (V (prod_encode_prefix @ prod_encode_ret_str)));;
  \<comment> \<open>cons_h' = prod_result;\<close>
  (cons_prefix @ cons_h_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_prod_encode_result));;
  \<comment> \<open>cons_t' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  (cons_prefix @ cons_t_str) ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str));;
  \<comment> \<open>cons_ret' = 0;\<close>
  (cons_prefix @ cons_ret_str) ::= (A (N 0));;
  \<comment> \<open>cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;\<close>
  \<comment> \<open>cons_ret_state = cons_imp cons_state;\<close>
  invoke_subprogram cons_prefix cons_IMP_Minus;;
  \<comment> \<open>cons_result = cons_ret cons_ret_state;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_cons_result ::=
    (A (V (cons_prefix @ cons_ret_str)));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' = cons_result;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_cons_result));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' = tl_result;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_tl_result));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str))
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop \<equiv>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' =
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' =
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str));;
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str ::=
    (A (V map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str))
"

definition map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus \<equiv>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond;;
  WHILE map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_while_cond \<noteq>0 DO (
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body;;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond
  );;
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop"

abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars \<equiv>
  {map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_hd_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_tl_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_fst'_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_snd'_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_nth_bit_tail_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_prod_encode_result,
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_cons_result}"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop_def

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s =
  \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
    (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc_str)),
   map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
    (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k_str)),
   map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
    (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n_str)),
   map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
    (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str))\<rparr>"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state_def
  hd_imp_to_HOL_state_def
  tl_imp_to_HOL_state_def
  fst'_imp_to_HOL_state_def
  snd'_imp_to_HOL_state_def
  nth_bit_tail_imp_to_HOL_state_def
  prod_encode_imp_to_HOL_state_def
  cons_imp_to_HOL_state_def

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators

declare nth_bit_tail_IMP_Minus_correct[functional_correctness]

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_function:
  "(invoke_subprogram p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s'
    \<Longrightarrow> s' (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str)
      = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret
          (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp
            (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s))"
  apply(induction "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s"
      arbitrary: s s' t rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply(subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps)
  apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_def prefix_simps)
  apply(vcg map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars)

  subgoal
    apply(subst (asm) (3) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop_def)
    apply(simp only: prefix_simps)
    apply(vcg map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars)
    by(fastforce simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(simp only: prefix_simps)
    by(fastforce simp: Let_def map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
    apply(simp only: prefix_simps)
    apply(vcg map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars)
    by(fastforce_sorted_premises simp: Let_def
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
    apply(simp only: prefix_simps)
    apply(vcg map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars)
    by(fastforce_sorted_premises simp: Let_def
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)
  done

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_pref)
                       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_pref v)\<rbrakk>
   \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_time_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_3
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators



thm functional_correctness

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_time:
  "(invoke_subprogram p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s'
    \<Longrightarrow> t = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0
              (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s)"
  apply(induction "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s"
      arbitrary: s s' t rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply(subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps)
  apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_def prefix_simps)

  apply(erule Seq_tE)+
  apply(erule While_tE_time)

  subgoal
    apply(subst (asm) (3) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop_def)
    apply(simp only: prefix_simps)
    apply(erule Seq_tE)+
    by (force simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators)

  apply(erule Seq_tE)+
  apply(simp add: add.assoc)
  apply(dest_com_gen_time)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(simp only: prefix_simps)
    by(fastforce simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
    apply(simp only: prefix_simps)
    apply(vcg map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars)
    by(fastforce_sorted_premises simp: Let_def
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_time_simps)

  subgoal
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(subst (asm) (1) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
    apply(simp only: prefix_simps)
    apply(erule Seq_tE)+
    apply(erule hd_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(73) by fastforce
    apply(erule tl_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(75) by fastforce
    apply(erule fst'_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(77) by fastforce
    apply(erule snd'_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(79) by fastforce
    apply(erule nth_bit_tail_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(81) by fastforce
    apply(erule prod_encode_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(83) by fastforce
    apply(erule cons_IMP_Minus_correct
        [where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(85) by fastforce
    by(fastforce_sorted_premises simp: Let_def
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_time_simps)
  done

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2)
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
    \<lbrakk>t = (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0
            (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state (p1 @ p2) s));
     s' (add_prefix (p1 @ p2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str) =
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret
            (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp
              (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state (p1 @ p2) s));
     \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
   \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_function
  by (auto simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_time)
    (meson map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_effects
      set_mono_prefix)








lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_def

function map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp::
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state \<Rightarrow> map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state" where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp s =
  (if map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition s \<noteq> 0
   then
    let next_iteration = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd s)
    in next_iteration
   else
    let ret = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop s
    in ret
  )"
  by simp+
termination
  apply (relation "measure <?>")
  apply (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps)+
  done

declare map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps [simp del]

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_correct:
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp s) =
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc <?arguments>"
  apply (induction s rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply (subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps)
  apply (subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc.simps)
  apply (simp del: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc.simps add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps Let_def)
  done

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time t s \<equiv>
  let
    hd_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + ;
    hd_ret' = 0;
    t = t + ;
    hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;
    t = t + ;
    hd_ret_state = hd_imp hd_state;
    t = t + ;
    hd_result = hd_ret hd_ret_state;
    t = t + ;
    tl_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + ;
    tl_ret' = 0;
    t = t + ;
    tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;
    t = t + ;
    tl_ret_state = tl_imp tl_state;
    t = t + ;
    tl_result = tl_ret tl_ret_state;
    t = t + ;
    fst'_state_p' = hd_result;
    t = t + ;
    fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;
    t = t + ;
    fst'_ret_state = fst'_imp fst'_state;
    t = t + ;
    fst'_result = fst'_state_p fst'_ret_state;
    t = t + ;
    snd'_state_p' = hd_result;
    t = t + ;
    snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;
    t = t + ;
    snd'_ret_state = snd'_imp snd'_state;
    t = t + ;
    snd'_result = snd'_state_p snd'_ret_state;
    t = t + ;
    nth_bit_tail_acc' = snd'_result;
    t = t + ;
    nth_bit_tail_n' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + ;
    nth_bit_tail_ret' = 0;
    t = t + ;
    nth_bit_tail_state = \<lparr>nth_bit_tail_acc = nth_bit_tail_acc',
                          nth_bit_tail_n = nth_bit_tail_n',
                          nth_bit_tail_ret = nth_bit_tail_ret'\<rparr>;
    t = t + ;
    nth_bit_tail_ret_state = nth_bit_tail_imp nth_bit_tail_state;
    t = t + ;
    nth_bit_tail_result = nth_bit_tail_ret nth_bit_tail_ret_state;
    t = t + ;
    prod_encode_a' = fst'_result;
    t = t + ;
    prod_encode_b' = nth_bit_tail_result;
    t = t + ;
    prod_encode_ret' = 0;
    t = t + ;
    prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',
                         prod_encode_b = prod_encode_b',
                         prod_encode_ret = prod_encode_ret'\<rparr>;
    t = t + ;
    prod_encode_ret_state = prod_encode_imp prod_encode_state;
    t = t + ;
    prod_result = prod_encode_ret prod_encode_ret_state;
    t = t + ;
    cons_h' = prod_result;
    t = t + ;
    cons_t' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + ;
    cons_ret' = 0;
    t = t + ;
    cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;
    t = t + ;
    cons_ret_state = cons_imp cons_state;
    t = t + ;
    cons_result = cons_ret cons_ret_state;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' = cons_result;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' = tl_result;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret s;
    t = t + ;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
    t = t + ;
  in
    ret
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time t s \<equiv>
  let
    condition = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s
    t = t + ;
  in
    ret
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time t s \<equiv>
  let
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;
    t = t + ;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =
      map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;
    t = t + ;
    ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',
           map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =
            map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>
    t = t + ;
  in
    ret
"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps

function map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time::
  "nat \<Rightarrow> map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state \<Rightarrow> nat" where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition_time 0 s +
  (if map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_compute_loop_condition s \<noteq> 0
    then
      (let
        t = t + 1;
        next_iteration =
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time (t + map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_time 0 s)
                         (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd s)
       in next_iteration)
    else
      (let
        t = t + 2;
        ret = t + map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_after_loop_time 0 s
       in ret)
  )"
  by auto
termination
  apply (relation "measure (<?> \<circ> snd)")
  by (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps)+
  done

declare map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps [simp del]

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time (Suc t) s) = Suc (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s)"
  by (induction t s rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.induct)
    ((subst (1 2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps);
      (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_upd_def))

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2_aux:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s) = t + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 s)"
  by (induction t arbitrary: s) (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc)+

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2:
  "t \<noteq> 0 \<Longrightarrow> (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time t s) = t + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 s)"
  by (rule map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2_aux)

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_3:
  "(map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time (a + b) s) = a + (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time b s)"
  by (induction a arbitrary: b s) (simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc)+


abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_while_cond \<equiv> ''condition''"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond \<equiv>
  \<comment> \<open>condition = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s\<close>
  Com.SKIP
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body \<equiv>
  \<comment> \<open>hd_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  \<comment> \<open>hd_ret' = 0;\<close>
  \<comment> \<open>hd_state = \<lparr>hd_xs = hd_xs', hd_ret = hd_ret'\<rparr>;\<close>
  \<comment> \<open>hd_ret_state = hd_imp hd_state;\<close>
  \<comment> \<open>hd_result = hd_ret hd_ret_state;\<close>
  \<comment> \<open>tl_xs' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  \<comment> \<open>tl_ret' = 0;\<close>
  \<comment> \<open>tl_state = \<lparr>tl_xs = tl_xs', tl_ret = tl_ret'\<rparr>;\<close>
  \<comment> \<open>tl_ret_state = tl_imp tl_state;\<close>
  \<comment> \<open>tl_result = tl_ret tl_ret_state;\<close>
  \<comment> \<open>fst'_state_p' = hd_result;\<close>
  \<comment> \<open>fst'_state = \<lparr>fst'_state_p = fst'_state_p'\<rparr>;\<close>
  \<comment> \<open>fst'_ret_state = fst'_imp fst'_state;\<close>
  \<comment> \<open>fst'_result = fst'_state_p fst'_ret_state;\<close>
  \<comment> \<open>snd'_state_p' = hd_result;\<close>
  \<comment> \<open>snd'_state = \<lparr>snd'_state_p = snd'_state_p'\<rparr>;\<close>
  \<comment> \<open>snd'_ret_state = snd'_imp snd'_state;\<close>
  \<comment> \<open>snd'_result = snd'_state_p snd'_ret_state;\<close>
  \<comment> \<open>nth_bit_tail_acc' = snd'_result;\<close>
  \<comment> \<open>nth_bit_tail_n' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  \<comment> \<open>nth_bit_tail_ret' = 0;\<close>
  \<comment> \<open>nth_bit_tail_state = \<lparr>nth_bit_tail_acc = nth_bit_tail_acc',\<close>
  \<comment> \<open>                      nth_bit_tail_n = nth_bit_tail_n',\<close>
  \<comment> \<open>                      nth_bit_tail_ret = nth_bit_tail_ret'\<rparr>;\<close>
  \<comment> \<open>nth_bit_tail_ret_state = nth_bit_tail_imp nth_bit_tail_state;\<close>
  \<comment> \<open>nth_bit_tail_result = nth_bit_tail_ret nth_bit_tail_ret_state;\<close>
  \<comment> \<open>prod_encode_a' = fst'_result;\<close>
  \<comment> \<open>prod_encode_b' = nth_bit_tail_result;\<close>
  \<comment> \<open>prod_encode_ret' = 0;\<close>
  \<comment> \<open>prod_encode_state = \<lparr>prod_encode_a = prod_encode_a',\<close>
  \<comment> \<open>                     prod_encode_b = prod_encode_b',\<close>
  \<comment> \<open>                     prod_encode_ret = prod_encode_ret'\<rparr>;\<close>
  \<comment> \<open>prod_encode_ret_state = prod_encode_imp prod_encode_state;\<close>
  \<comment> \<open>prod_result = prod_encode_ret prod_encode_ret_state;\<close>
  \<comment> \<open>cons_h' = prod_result;\<close>
  \<comment> \<open>cons_t' = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  \<comment> \<open>cons_ret' = 0;\<close>
  \<comment> \<open>cons_state = \<lparr>cons_h = cons_h', cons_t = cons_t', cons_ret = cons_ret'\<rparr>;\<close>
  \<comment> \<open>cons_ret_state = cons_imp cons_state;\<close>
  \<comment> \<open>cons_result = cons_ret cons_ret_state;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' = cons_result;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' = tl_result;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret s;\<close>
  \<comment> \<open>ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>\<close>
  Com.SKIP
"

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop \<equiv>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k s;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n s;\<close>
  \<comment> \<open>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret' =\<close>
  \<comment> \<open>  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc s;\<close>
  \<comment> \<open>ret = \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc =\<close>
  \<comment> \<open>        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_acc',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k =\<close>
  \<comment> \<open>        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_k',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n =\<close>
  \<comment> \<open>        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_n',\<close>
  \<comment> \<open>       map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret =\<close>
  \<comment> \<open>        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret'\<rparr>\<close>
  Com.SKIP
"

definition map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus where
  "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus \<equiv>
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond;;
  WHILE map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_while_cond \<noteq>0 DO (
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body;;
    map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond
  );;
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop"

abbreviation "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars\<equiv>
  {}"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_after_loop_def

definition "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s =
  \<lparr>map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc<?> = (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc<?>)),
   map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc<?> = (s (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc<?>))\<rparr>"

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state_def

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_function:
  "(invoke_subprogram p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     s' (add_prefix p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str)
      = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret
          (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s))"
  apply(induction "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s" arbitrary: s s' t
    rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply(subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.simps)
  apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_def prefix_simps)
  apply(erule Seq_E)+
  apply(erule While_tE)

  subgoal
    apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps prefix_simps)
    apply(erule Seq_E)+
    apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(999) by fastforce
    by(fastforce simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators)

  apply(erule Seq_E)+
  apply(dest_com_gen)

  subgoal
      apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def prefix_simps)
      apply(erule Seq_E)+
      apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
      subgoal premises p using p(999) by fastforce
      by(fastforce simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
      apply(subst (asm) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
      apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def prefix_simps)
      apply(erule Seq_E)+
      apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
      subgoal premises p using p(999) by fastforce
      by (simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators Let_def, force)

  subgoal
      apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def prefix_simps
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
      apply(erule Seq_E)+
      apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
      subgoal premises p using p(999) by fastforce
      by (simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_simps
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators Let_def, force)
  done

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_effects:
  "\<lbrakk>(invoke_subprogram (p @ map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_pref) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    v \<in> vars; \<not> (prefix map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_pref v)\<rbrakk>
   \<Longrightarrow> s (add_prefix p v) = s' (add_prefix p v)"
  using com_add_prefix_valid'' com_only_vars prefix_def
  by blast

lemmas map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_time_simps =
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_2
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time_acc_3
  map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_time:
  "(invoke_subprogram p map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s' \<Longrightarrow>
     t = map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s)"
  apply(induction "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state p s" arbitrary: s s' t
      rule: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp.induct)
  apply(subst map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time.simps)
  apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_def prefix_simps)

  apply(erule Seq_tE)+
  apply(erule While_tE_time)

  subgoal
    apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps prefix_simps)
    apply(erule Seq_tE)+
    apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(999) by fastforce
    by (force simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_subprogram_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators)

  apply(erule Seq_tE)+
  apply(simp add: add.assoc)
  apply(dest_com_gen_time)

  subgoal
    apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def prefix_simps)
    apply(erule Seq_tE)+
    apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(999) by fastforce
    by(fastforce simp add: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_simps)

  subgoal
    apply(subst (asm) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def)
    apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def prefix_simps)
    apply(erule Seq_tE)+
    apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(999) by fastforce
    by (simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_subprogram_time_simps
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_state_translators Let_def, force)

  subgoal
    apply(simp only: prefix_simps map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_init_while_cond_def
        map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_loop_body_def)
    apply(erule Seq_tE)+
    apply(erule <?>_IMP_Minus_correct[where vars = "map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_vars"])
    subgoal premises p using p(999) by fastforce
    apply(simp only: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_complete_time_simps Let_def)
    by force

  done

lemma map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct:
  "\<lbrakk>(invoke_subprogram (p1 @ p2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus, s) \<Rightarrow>\<^bsup>t\<^esup> s';
    \<And>v. v \<in> vars \<Longrightarrow> \<not> (set p2 \<subseteq> set v);
    \<lbrakk>t = (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_time 0 (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state (p1 @ p2) s));
     s' (add_prefix (p1 @ p2) map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret_str) =
          map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_ret (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp
                                        (map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_imp_to_HOL_state (p1 @ p2) s));
     \<And>v. v \<in> vars \<Longrightarrow> s (add_prefix p1 v) = s' (add_prefix p1 v)\<rbrakk>
   \<Longrightarrow> P\<rbrakk> \<Longrightarrow> P"
  using map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_function
  by (auto simp: map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_time)
    (meson map_IMP_Minus_State_To_IMP_Minus_Minus_partial_acc_IMP_Minus_correct_effects set_mono_prefix)


end