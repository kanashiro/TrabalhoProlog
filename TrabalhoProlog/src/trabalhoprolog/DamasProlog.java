/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package trabalhoprolog;

import alice.tuprolog.InvalidTheoryException;
import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Theory;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

/**
 *
 * @author WillianKanashiro
 */
public class DamasProlog {
    private String Depth, jogadorAtual, tabuleiroAtual, Move, vencedor;
    private boolean fim;//, invalido;
    
    public DamasProlog(String Depth){
        fim = false;
        //invalido = false;
         this.Depth = Depth;
        this.tabuleiroAtual = "b(n, x, n, x, n, x, n, x, x, n, x, n, x, n, x, n, n, x, n, x, n, x, n, x, e, n, e, n, e, n, e, n, n, e, n, e, n, e, n, e, o, n, o, n, o, n, o, n, n, o, n, o, n, o, n, o, o, n, o, n, o, n, o, n)";
    }
    
    
    public void getMove(){
        Scanner ler = new Scanner(System.in);
        System.out.print("Movimento: ");
        this.Move = ler.next();
    }
    
    public void iniciar(){
        //a interface deve conter os seguintes métodos, passando como string o nível(2 ou 5) e quem comeca(comp ou human)
        //this.Depth = interface.getNivel();
        this.jogadorAtual = "human";
    }
    
    public String processar(String solution){
        int i=0;
        while(!"b(".equals(solution.substring(i,i+2)) && i<solution.length()){
            i++;
        }
        
        String valor = solution.substring(i,solution.length());
        //System.out.println(valor);
        
        if("b(i)".equals(valor)){
            System.out.println("invalido. jogue novamente");
            return "movimento invalido";
        }
        else{
            if("b(x)".equals(valor)){
                this.fim = true;
                this.vencedor = "computador";
                return this.vencedor;
            }
            else{
                if("b(o)".equals(valor)){
                    this.fim = true;
                    this.vencedor = "humano";
                    return this.vencedor;
                }
                else{
               // this.invalido = true;
                
                this.tabuleiroAtual= valor;
                //interface.atualizaTabuleiro(this.tabuleiroAtual);
                this.trocaJogador();
                System.out.println(this.tabuleiroAtual);
                
                return this.tabuleiroAtual;
                }
            }
        }
    }
    
    
    public void trocaJogador(){
        if("comp".equals(this.jogadorAtual))
            this.jogadorAtual="human";
        else
            this.jogadorAtual="comp";
    }
    
    
    public static void main(String[] args) throws FileNotFoundException, InvalidTheoryException, IOException {
        
        
        //cria jogo
        DamasProlog jogo = new DamasProlog("1");
        final TrabalhoDamas_Tabuleiro tabuleiro = new TrabalhoDamas_Tabuleiro();
        
         java.awt.EventQueue.invokeLater(new Runnable() {
            @Override
            public void run() {
                tabuleiro.setVisible(true);
            }
        });
        //inicia engine e abre o arquivo .pl
        Prolog engine = new Prolog();
        Theory theory = new Theory(new FileInputStream("damas.pl"));
        try{
        engine.setTheory(theory);
        }catch(InvalidTheoryException e){
        }
        SolveInfo info;
        /*try{
        info = engine.solve("findall(NewBoard, (turn_to_sign(x,Sign),validMove(b(n,e,n,e,n,e,n,x,p,n,e,n,e,n,e,n,n,e,n,e,n,e,n,x,e,n,e,n,o,n,o,n,n,o,n,o,n,e,n,e,e,n,o,n,e,n,p,n,n,e,n,e,n,e,n,o,e,n,e,n,e,n,e,n), Sign, NewBoard)), []).");
        System.out.println(info);
        }
        catch(Exception e){}*/
        
        jogo.iniciar();
                
        while(!jogo.fim){
            System.out.println(jogo.jogadorAtual);
            try{
                if("comp".equals(jogo.jogadorAtual)){
                    //info = engine.solve("playO(B).");
                    //Term queryC = new Struct("play",new Struct("comp"),new Struct("x"), new String("jogo.tabuleiroAtual"),new Var("NewBoarder"),new String("jogo.Depth"));
                    String stringC = "play(comp,x,"+jogo.tabuleiroAtual+",NewBoard,"+jogo.Depth+").";
                    
                    //System.out.println(stringC);
                    info = engine.solve(stringC);
                   
                }
                else{
                    //jogo.Move = interface.getMove();
                    //jogo.getMove();
                    jogo.Move = tabuleiro.pegarMovimento();
                    while(jogo.Move.length() != 7){
                         jogo.Move = tabuleiro.pegarMovimento();
                    }
                    
                    //Term queryH = new Struct("play",new Struct("human"),new Struct("o"), new String("jogo.tabuleiroAtual"),new Var("NewBoarder"),new String("jogo.Move"));
                    String stringH ="play(human,o,"+jogo.tabuleiroAtual+",NewBoarder,"+jogo.Move+").";
                    info = engine.solve(stringH);
                    
                    
                }
                //System.out.println(info);
                //System.out.println(info.getSolution());
                String jogadaAtual = jogo.processar(info.toString());
                if(jogadaAtual.length()>50){
                tabuleiro.colocaPecas(jogadaAtual);}
            }
            catch(Exception e){
            }
        }
        
        System.out.println(jogo.jogadorAtual+" ganhou");
        
        
        
        
        
        
    }
}
