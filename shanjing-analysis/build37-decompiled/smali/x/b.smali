.class public final synthetic Lx/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lx/c;

.field public final synthetic e:Ljava/lang/String;

.field public final synthetic f:I

.field public final synthetic g:Lx/c$f;

.field public final synthetic h:Ljava/nio/ByteBuffer;

.field public final synthetic i:J


# direct methods
.method public synthetic constructor <init>(Lx/c;Ljava/lang/String;ILx/c$f;Ljava/nio/ByteBuffer;J)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lx/b;->d:Lx/c;

    iput-object p2, p0, Lx/b;->e:Ljava/lang/String;

    iput p3, p0, Lx/b;->f:I

    iput-object p4, p0, Lx/b;->g:Lx/c$f;

    iput-object p5, p0, Lx/b;->h:Ljava/nio/ByteBuffer;

    iput-wide p6, p0, Lx/b;->i:J

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 7

    iget-object v0, p0, Lx/b;->d:Lx/c;

    iget-object v1, p0, Lx/b;->e:Ljava/lang/String;

    iget v2, p0, Lx/b;->f:I

    iget-object v3, p0, Lx/b;->g:Lx/c$f;

    iget-object v4, p0, Lx/b;->h:Ljava/nio/ByteBuffer;

    iget-wide v5, p0, Lx/b;->i:J

    invoke-static/range {v0 .. v6}, Lx/c;->i(Lx/c;Ljava/lang/String;ILx/c$f;Ljava/nio/ByteBuffer;J)V

    return-void
.end method
