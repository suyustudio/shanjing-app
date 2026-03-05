.class public final synthetic Lr/z;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Z

.field public final synthetic e:Ljava/lang/String;

.field public final synthetic f:Lj0/k$d;

.field public final synthetic g:Ljava/lang/Boolean;

.field public final synthetic h:Lr/i;

.field public final synthetic i:Lj0/j;

.field public final synthetic j:Z

.field public final synthetic k:I


# direct methods
.method public synthetic constructor <init>(ZLjava/lang/String;Lj0/k$d;Ljava/lang/Boolean;Lr/i;Lj0/j;ZI)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-boolean p1, p0, Lr/z;->d:Z

    iput-object p2, p0, Lr/z;->e:Ljava/lang/String;

    iput-object p3, p0, Lr/z;->f:Lj0/k$d;

    iput-object p4, p0, Lr/z;->g:Ljava/lang/Boolean;

    iput-object p5, p0, Lr/z;->h:Lr/i;

    iput-object p6, p0, Lr/z;->i:Lj0/j;

    iput-boolean p7, p0, Lr/z;->j:Z

    iput p8, p0, Lr/z;->k:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 8

    iget-boolean v0, p0, Lr/z;->d:Z

    iget-object v1, p0, Lr/z;->e:Ljava/lang/String;

    iget-object v2, p0, Lr/z;->f:Lj0/k$d;

    iget-object v3, p0, Lr/z;->g:Ljava/lang/Boolean;

    iget-object v4, p0, Lr/z;->h:Lr/i;

    iget-object v5, p0, Lr/z;->i:Lj0/j;

    iget-boolean v6, p0, Lr/z;->j:Z

    iget v7, p0, Lr/z;->k:I

    invoke-static/range {v0 .. v7}, Lr/c0;->b(ZLjava/lang/String;Lj0/k$d;Ljava/lang/Boolean;Lr/i;Lj0/j;ZI)V

    return-void
.end method
