/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package trabalhoprolog;

import mProlog.PrologEngine;
import mProlog.PrologQuery;
import mProlog.PrologTerm;

/**
 *
 * @author WillianKanashiro
 */
public class TrabalhoProlog {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // escrever o arquivo
		 PrologEngine baseProlog = new PrologEngine(); 
		 baseProlog.add("estuda(rafael,turma2015)");
		 baseProlog.add("estuda(kanashiro,turma2015)");
		 baseProlog.add("estuda(marcella,turma2015)");
		 baseProlog.add("estuda(leonardo,turma2008)");
		 baseProlog.add("estuda(harryson,turma2009)");

		 baseProlog.add("colegas(A,B):-estuda(A,C),estuda(B,C)"); 

		 // escrever as minhas perguntas
		 PrologTerm pergunta1 = PrologTerm.create("colegas(A,B)"); 
		 PrologTerm pergunta2 = PrologTerm.create("estuda(X,turma2015)"); 
		 
		 // executar as queries
		 PrologQuery query = new PrologQuery(baseProlog, pergunta2);
		 PrologTerm[] solution = query.solution(); 
		 
                 
                
                 while(solution != null) 
		 {
			 System.out.println(solution[0].getVariableValue()); 
                         solution = query.solution();

		 }
                 
    }
}
