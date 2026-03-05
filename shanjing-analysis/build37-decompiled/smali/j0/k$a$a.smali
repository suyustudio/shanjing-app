.class Lj0/k$a$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$d;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lj0/k$a;->a(Ljava/nio/ByteBuffer;Lj0/c$b;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lj0/c$b;

.field final synthetic b:Lj0/k$a;


# direct methods
.method constructor <init>(Lj0/k$a;Lj0/c$b;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lj0/k$a$a;->b:Lj0/k$a;

    iput-object p2, p0, Lj0/k$a$a;->a:Lj0/c$b;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/Object;)V
    .locals 2

    iget-object v0, p0, Lj0/k$a$a;->a:Lj0/c$b;

    iget-object v1, p0, Lj0/k$a$a;->b:Lj0/k$a;

    iget-object v1, v1, Lj0/k$a;->b:Lj0/k;

    invoke-static {v1}, Lj0/k;->a(Lj0/k;)Lj0/l;

    move-result-object v1

    invoke-interface {v1, p1}, Lj0/l;->a(Ljava/lang/Object;)Ljava/nio/ByteBuffer;

    move-result-object p1

    invoke-interface {v0, p1}, Lj0/c$b;->a(Ljava/nio/ByteBuffer;)V

    return-void
.end method

.method public b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 2

    iget-object v0, p0, Lj0/k$a$a;->a:Lj0/c$b;

    iget-object v1, p0, Lj0/k$a$a;->b:Lj0/k$a;

    iget-object v1, v1, Lj0/k$a;->b:Lj0/k;

    invoke-static {v1}, Lj0/k;->a(Lj0/k;)Lj0/l;

    move-result-object v1

    invoke-interface {v1, p1, p2, p3}, Lj0/l;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/nio/ByteBuffer;

    move-result-object p1

    invoke-interface {v0, p1}, Lj0/c$b;->a(Ljava/nio/ByteBuffer;)V

    return-void
.end method

.method public c()V
    .locals 2

    iget-object v0, p0, Lj0/k$a$a;->a:Lj0/c$b;

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Lj0/c$b;->a(Ljava/nio/ByteBuffer;)V

    return-void
.end method
